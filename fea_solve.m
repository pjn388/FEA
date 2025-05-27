    % This file does all the calculations for any given node, element, and constraint lists provided, should be extendable...
    % Making this work for 3D or more than 2 nodes per element should be doable but will be a pain in the ass


function fea_solve(nodes, elements, constraints, varargin)
        % Input parser (matlab makes the simple tasks hard)
        p = inputParser;
        addParameter(p, 'name', "Default");
        addParameter(p, 'node_names', cellfun(@(x) x.uuid, nodes));
        parse(p, varargin{:});
        name = p.Results.name;
        node_names = p.Results.node_names;


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
    get_stiffness_tables = cell(1, length(elements));
    for i = 1:length(elements)
        get_stiffness_tables{1, i} = elements{1, i}.get_stiffness_table();
    end
    % combine the stiffness tables into global table
    global_K_table = sortrows(combine_tables(get_stiffness_tables{:}), 'RowNames');


    % collect loading tables
    get_loading_tables = cell(1, length(elements));
    for i = 1:length(elements)
        get_loading_tables{1, i} = elements{1, i}.get_loading_table();
    end
    % combine the loading tables into global table
    global_F_table = sortrows(combine_tables(get_loading_tables{:}), 'RowNames');



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

    % save the sumbolic

    symbolic_global_K_table = global_K_table;
    symbolic_global_F_table = global_F_table;

    % apply thermal fixed temperature constraints
    for i = 1:length(elements)
        if ~isa(elements{i}, 'Thermal')
            continue;
        end

        for j = 1:length(elements{i}.boundaries)
            boundary = elements{i}.boundaries{j};
            if ~isa(boundary, 'FixedTemperatureBoundary')
                continue;
            end
            % we need to zero out all temperature parts of the stiffness table that are associated with this boundary condition
            % then set a 1 in the stiffness where the temp for this boundary will be multiplied across to 1
            % then set the solution vector for this boundary to the fixed temp

            % zeroing and setitng the identity bit for the boundaries
            node_a_row_name = "Node_" + boundary.node_a.uuid + "_" + "T";
            global_K_table{node_a_row_name, :} = zeros(1, width(global_K_table));
            global_K_table{node_a_row_name, node_a_row_name} = 1;

            node_b_row_name = "Node_" + boundary.node_b.uuid + "_" + "T";
            global_K_table{node_b_row_name, :} = zeros(1, width(global_K_table));
            global_K_table{node_b_row_name, node_b_row_name} = 1;

            % setting the fixed temp in the solution vector


            node_a_row_name = "Node_" + boundary.node_a.uuid + "_" + "T";
            global_F_table{node_a_row_name, 'Load_1'} = boundary.T_fixed;

            node_b_row_name = "Node_" + boundary.node_b.uuid + "_" + "T";
            global_F_table{node_b_row_name, 'Load_1'} = boundary.T_fixed;
        end
    end

    % apply the fixed node boundary conditions
    % go through the stiffness table and force table and eliminate the fixed nodes rows and columns

    % Create a list of row/column names to eliminate based on fixed nodes
    rows_to_eliminate = {};
    for i = 1:length(nodes)
        node = nodes{1, i};
        for dof_index = 1:length(node.dof)
            if isempty(node.constrained_dof) % Why does matlab make this line neccessary this is some dumb language
                continue;
            elseif ~ismember(node.dof(dof_index), node.constrained_dof)
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

    % calculate the solutions
    % If u encounter an error on this line then you are trying to use symbolics
    % this program uses but doesnt support symbolics its simply a hack ive used to calculate reactive heat flux
    solutions = inv(double(global_K))*double(global_F);

    % elimated dof's will have the same value as the dos that elimated them. sub that value back into solutions
    for i = 1:length(eliminated_dofs)
        row_name = eliminated_dofs(i).row_name;
        eliminated_by = eliminated_dofs(i).eliminated_by;

        % Find the indexes corresponding to the row_name and eliminated_by in the solution vector
        index_to_substitute = find(strcmp(row_names_array, row_name));
        index_substitute_with = find(strcmp(row_names_array, eliminated_by));

        % Check that verticies were found
        if (isempty(index_to_substitute) || isempty(index_substitute_with))
            disp("ERROR: vertex not found in array");
            continue
        end

        % Substitute the solution value
        solutions(index_to_substitute) = solutions(index_substitute_with);
    end

    % calculate reactive heat flux
    symbolic_global_K = table2array(symbolic_global_K_table)
    symbolic_global_F = table2array(symbolic_global_F_table)

    symbolic_eq = symbolic_global_F == symbolic_global_K * solutions

    % factor to exagerate the solution by for rendering
    exageration_factor = 1;

    % iterate through the nodes and add the solutions to their solutions
    for i = 1:length(nodes)
        if isa(nodes{i}, 'FixedNode2D') || isa(nodes{i}, 'PinnedNode2D')
            continue;
        end

        node = nodes{i};

        node_solutions = zeros(length(node.dof));

        for dof_index = 1:length(node.dof)
            dof = node.dof{1, dof_index};
            row_name = "Node_" + node.uuid + "_" + dof;
            
            % Find the index of the solution in the symbolic_vars
            solution_index = find(strcmp(string(symbolic_vars), row_name));
            
            % If no displaccement found ignore and warn
            if isempty(solution_index)
                warning("Could not find the solution index: "+solution_index)
                continue;
            end
            node_solutions(dof_index) = solutions(solution_index);
        end
        node.set_solution(node.dof, node_solutions);
        if ~isempty(symvar(symbolic_eq(solution_index)))
            node.q_flux = double(solve(symbolic_eq(solution_index), sym("q_flux")));
        end
        disp("node_"+node_names{i}+": "+node.display_())
    end

    % render displaced mesh
    hold on;
    render_structure(elements, nodes, true, legendHandles, legendLabels, name);

end