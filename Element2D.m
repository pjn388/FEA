% Represents a base 2D element
classdef Element2D
    properties (Access = private) % ensure these cannot be public accessed as they may not be in a correct state unless accessed by the getter
        stiffness_matrix
        loading_matrix
        shape_matrix
        displacement_matrix
    end

    properties
        node_1
        node_2
        dof
        E
        T
    end
    
    methods
        function obj = Element2D(node_1, node_2, dof, E)
            obj.dof = dof;
            obj.E = E;
            % update node dof so the nodes know how many dof they have based upon the elements that use them
            node_1.dof = unique([node_1.dof, obj.dof]);
            node_2.dof = unique([node_2.dof, obj.dof]);
            % update node loading based upon dof, we have no loading untill an external loading is applied
            node_1.loading = zeros(1, length(node_1.dof));
            node_2.loading = zeros(1, length(node_2.dof));
            
            obj.node_1 = node_1;
            obj.node_2 = node_2;
        end
        
        % helper function to make displaying an element a usefull experience
        function display(obj)
            fprintf('%s:\n', class(obj));
            displayNode(obj.node_1);
            displayNode(obj.node_2);
            fprintf('  Stiffness Matrix:\n');
            disp(obj.get_stiffness_matrix());
            % i hate nested function defs but im feeling lazy
            function displayNode(node)
                fprintf('  %s: %s\n', class(node), node.uuid);
            end
        end
        
        % getters to ensure that calculations are performed before accessing values
        function tranformation_matrix = get_tranformation_matrix(obj)
            tranformation_matrix = obj.T;
        end
        function shape_matrix = get_shape_matrix(obj, x, y) % this is overwritten by the child classes based upon the element type
            shape_matrix = obj.shape_matrix;
        end
        function stiffness_matrix = get_stiffness_matrix(obj) % this is overwritten by the child classes based upon the element type
            stiffness_matrix = obj.stiffness_matrix;
        end
        function loading_matrix = get_loading_matrix(obj)
            if (length(obj.node_1.dof) ~= length(obj.node_1.loading)) || (length(obj.node_2.dof) ~= length(obj.node_2.loading))
                warning("Loading and dof are differnt size this should be an impossible state. How have you done this? (it's probably my fault)")
            end
        
            node_1_loading = get_relevant_dof(obj.node_1.dof, obj.node_1.loading, obj.dof);
            node_2_loading = get_relevant_dof(obj.node_2.dof, obj.node_2.loading, obj.dof);
        
            arrayout = zeros(length(obj.dof)*2, 1);
            % assing the correct section of the out matrix to the correct setion of the nodes loading matrix
            arrayout(1:length(node_1_loading)) = node_1_loading(:);
            arrayout(length(obj.dof)+1:length(obj.dof)+length(node_2_loading)) = node_2_loading(:);
        
            obj.loading_matrix = arrayout;
            loading_matrix = obj.loading_matrix;
        end
        function displacement_matrix = get_displacement_matrix(obj)
            if isa(obj.node_1, 'FixedNode2D') % fixed nodes have 0 displacement by definiton
                obj.node_1.displacement = zeros(length(obj.node_1.dof), 1);
            end
            if isa(obj.node_2, 'FixedNode2D') % fixed nodes have 0 displacement by definiton
                obj.node_2.displacement = zeros(length(obj.node_2.dof), 1);
            end
            if (length(obj.node_1.dof) ~= length(obj.node_1.displacement)) || (length(obj.node_2.dof) ~= length(obj.node_2.displacement))
                warning("Displacement and dof are differnt size this should be an impossible state. How have you done this? (it's probably my fault)")
            end
            node_1_displacement = get_relevant_dof(obj.node_1.dof, obj.node_1.displacement, obj.dof);
            node_2_displacement = get_relevant_dof(obj.node_2.dof, obj.node_2.displacement, obj.dof);

            arrayout = zeros(length(obj.dof)*2, 1);

            % assing the correct section of the out matrix to the correct setion of the nodes displacement matrix
            arrayout(1:length(node_1_displacement)) = node_1_displacement(:);
            arrayout(length(obj.dof)+1:length(obj.dof)+length(node_2_displacement)) = node_2_displacement(:);

            obj.displacement_matrix = arrayout;
            displacement_matrix = obj.displacement_matrix;
        end

        % make relevent matrix tables
        function T = stiffness_table(obj)
            T = matrix_to_table(obj.get_stiffness_matrix(), obj.node_1, obj.node_2, obj.dof);
        end
        function T = loading_table(obj)
            T = matrix_to_table(obj.get_loading_matrix(), obj.node_1, obj.node_2, obj.dof, isload=true);
        end

        function stress = get_stress(obj, x, y)
            obj.E*obj.get_shape_matrix(x, y)
            obj.get_displacement_matrix()
            stress = obj.E*obj.get_shape_matrix(x, y)*obj.get_displacement_matrix();
        end
        
    end
end

% generic matrix to table conversion. Takes a dof alligned matrix for an element and makes a labeled table based on its dofs 
% This use usefull as it labels rows and columns to allow for commbination based on these row/column values 
function T = matrix_to_table(matrix_data, node_1, node_2, dof, varargin)

    % Input parser (matlab makes the simple tasks hard)
    p = inputParser;
    addParameter(p, 'isload', false, @islogical);
    parse(p, varargin{:});
    isload = p.Results.isload;
    
    dof_labels = strings(1, 2 * length(dof));
    for i = 1:length(dof)
        dof_labels(i) = "Node_" + node_1.uuid + "_" + dof(i);
        dof_labels(length(dof) + i) = "Node_" + node_2.uuid + "_" + dof(i);
    end
    
    % sometime the impossible is possible and debuging the impossible when its not clear is impossible
    if size(matrix_data,1) ~= length(dof_labels)
        warning('Stiffness matrix size does not match expected number of DOFs. This error should NEVER happen something has gone seriosuly wrong.');
        T = table();
        return;
    end
    
    % actually do conversion
    if isload
        num_cols = size(matrix_data, 2);
        col_labels = strings(1, num_cols);
        for i = 1:num_cols
            col_labels(i) = "Load_" + i;
        end
        T = array2table(matrix_data, ...
            'VariableNames', col_labels, ...
            'RowNames', dof_labels);
    else
        T = array2table(matrix_data, ...
            'VariableNames', dof_labels, ...
            'RowNames', dof_labels);
    end
end


% gets the relevent dof's values from an array of dof's and their values
function relevant_values = get_relevant_dof(dofs, values, relevant_dofs)
    relevant_values = zeros(length(relevant_dofs), 1);
    for i = 1:length(relevant_dofs)
        dof_index = find(strcmp(dofs, relevant_dofs{i}));
        if ~isempty(dof_index)
            relevant_values(i) = values(dof_index);
        end
    end
end