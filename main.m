% This file does all the calculations for any given node, element, and constraint lists provided, should be extendable...
% Making this work for 3D or more than 2 nodes per element should be doable but will be a pain in the ass


% plot the initial state
figure;
hold on;
[legendHandles, legendLabels] = render_structure(elements, nodes, false, [], cell(0, 0), name);


% Does somke nice rendering of nodes and elements TODO: uncomment prior to submission
% % What do our nodes and elemnts look like
% for i = 1:length(nodes)
%     nodes{1, i}.display();
% end

% for i = 1:length(elements)
%     elements{1, i}.display()
% end

% collect stiffness tables
stiffness_tables = cell(1, length(elements));
for i = 1:length(elements)
    stiffness_tables{1, i} = elements{1, i}.stiffness_table();
end
% combine the stiffness tables into global table
global_K_table = sortrows(combine_tables(stiffness_tables{:}), 'RowNames');


% collect loading tables
loading_tables = cell(1, length(elements));
for i = 1:length(elements)
    loading_tables{1, i} = elements{1, i}.loading_table();
end
% combine the loading tables into global table
global_F_table = sortrows(combine_tables(loading_tables{:}, dosum=false), 'RowNames');



% apply the constraints to the relevent DOF's
eliminated_dofs = struct('row_name', {}, 'eliminated_by', {}); % Initialize a struct to store eliminated DOFs

for i = 1:length(constraints)
    % get some node info for indexing the global stiffness table
    node_1 = constraints{1, i}.node_1;
    node_2 = constraints{1, i}.node_2;
    dof_list = constraints{1, i}.dof;

    for j = 1:length(constraints{1, i}.dof)
        dof = dof_list(j);

        % this is out table index for the relevent nodes
        row_name_1 = "Node_" + node_1.uuid + "_" + dof;
        row_name_2 = "Node_" + node_2.uuid + "_" + dof;

        % Add column for node_1 dof to node_2 dof
        col_index_1 = find(strcmp(global_K_table.Properties.VariableNames, row_name_1));
        col_index_2 = find(strcmp(global_K_table.Properties.VariableNames, row_name_2));

        global_K_table{:, col_index_2} = global_K_table{:, col_index_2} + global_K_table{:, col_index_1};

        % Store the eliminated DOF information for substitution later
        eliminated_dofs(end+1).row_name = row_name_1;
        eliminated_dofs(end).eliminated_by = row_name_2;
        
        % set column to zero and add 1 in identity position
        global_K_table{:, col_index_1} = 0;
        global_K_table{row_name_1, row_name_1} = 1;

        % add row for node_1 dof to node_2 dof
        row_index_1 = find(strcmp(global_K_table.Properties.RowNames, row_name_1));
        row_index_2 = find(strcmp(global_K_table.Properties.RowNames, row_name_2));
        global_K_table{row_index_2, :} = global_K_table{row_index_2, :} + global_K_table{row_index_1, :};

        % zero row and add identiy value back
        global_K_table{row_index_1, :} = 0;
        global_K_table{row_name_1, row_name_1} = 1;
    end
end

% apply the fixed node boundary conditions
% go through the stiffness table and force table and eliminate the fixed nodes rows and columns

% Create a list of row/column names to eliminate based on fixed nodes
rows_to_eliminate = {};
for i = 1:length(nodes)
    if ~isa(nodes{i}, 'FixedNode2D') && ~isa(nodes{i}, 'PinnedNode2D')  % ignore Free nodes
        continue;
    end

    node = nodes{1, i};
    for dof_index = 1:length(node.dof)
        if ~ismember(node.dof(dof_index), node.constrained_dof)
            continue;
        end

        dof = node.dof{1, dof_index};
        row_name = "Node_" + node.uuid + "_" + dof;
        rows_to_eliminate = [rows_to_eliminate, row_name];
    end
end

% Eliminate rows and columns from global_K_table
global_K_table(rows_to_eliminate,:) = [];
global_K_table(:,rows_to_eliminate) = [];

% Eliminate rows from global_F_table (assuming rows correspond to nodes)
global_F_table(rows_to_eliminate,:) = [];

global_K = table2array(global_K_table);
global_F = table2array(global_F_table);

% convert row names to a vector matrix of symbolic vars (should make subbing names back in easyer later)...
% turns out this was almost completly usless
row_names_array = global_K_table.Properties.RowNames;
symbolic_vars = sym(zeros(length(row_names_array), 1));

for i = 1:length(symbolic_vars)
    symbolic_vars(i) = sym(row_names_array{i});
end

% calculate the displacements
displacements = inv(global_K)*global_F;

% elimated dof's will have the same value as the dos that elimated them. sub that value back into displacements
for i = 1:length(eliminated_dofs)
    row_name = eliminated_dofs(i).row_name;
    eliminated_by = eliminated_dofs(i).eliminated_by;

    % Find the indexes corresponding to the row_name and eliminated_by in the displacement vector
    index_to_substitute = find(strcmp(row_names_array, row_name));
    index_substitute_with = find(strcmp(row_names_array, eliminated_by));

    % Check that verticies were found
    if (isempty(index_to_substitute) || isempty(index_substitute_with))
        disp("ERROR: vertex not found in array")
        continue
    end

    % Substitute the displacement value
    displacements(index_to_substitute) = displacements(index_substitute_with);
end

% not used but might be usfull later
% eq = symbolic_vars == double(displacements);

% factor to exagerate the displacement by for rendering
exageration_factor = 1;

% iterate through the nodes and add the displacements to their position
for i = 1:length(nodes)
    if isa(nodes{i}, 'FixedNode2D') || isa(nodes{i}, 'PinnedNode2D')
        continue;
    end

    node = nodes{i};

    node_displacements = zeros(length(node.dof));

    for dof_index = 1:length(node.dof)
        dof = node.dof{1, dof_index};
        row_name = "Node_" + node.uuid + "_" + dof;
        
        % Find the index of the displacement in the symbolic_vars
        displacement_index = find(strcmp(string(symbolic_vars), row_name));
        
        % If no displaccement found ignore and warn
        if isempty(displacement_index)
            warning("Could not find the displacement index: "+displacement_index)
            continue;
        end
        node_displacements(dof_index) = displacements(displacement_index);
    end
    node.set_displacement(node.dof, node_displacements);
    disp("node_"+node_names{i}+": "+node.display_())
end

% render displaced mesh
hold on;
render_structure(elements, nodes, true, legendHandles, legendLabels, name);