% Generic rectangle element
classdef ThermalRectangleElement < Element4Nodes & Thermal
    properties
        q_dot
    end
    methods
        function obj = ThermalRectangleElement(node_1, node_2, node_3, node_4, material, q_dot)
            obj = obj@Thermal();
            % Collect x and y coordinates
            x_coords = [node_1.x, node_2.x, node_3.x, node_4.x];
            y_coords = [node_1.y, node_2.y, node_3.y, node_4.y];
            
            % Check for unique x and y coordinates
            unique_x = unique(x_coords);
            unique_y = unique(y_coords);
            
            % Validate that there are exactly 2 unique x and y coordinates
            if length(unique_x) ~= 2 || length(unique_y) ~= 2
                error('The provided nodes do not form a rectangle.');
            end
            
            % Sort the unique coordinates
            unique_x = sort(unique_x);
            unique_y = sort(unique_y);
            
            % Create the expected corner nodes based on sorted unique coordinates
            node_bl = Node2D(unique_x(1), unique_y(1));
            node_br = Node2D(unique_x(2), unique_y(1));
            node_tr = Node2D(unique_x(2), unique_y(2));
            node_tl = Node2D(unique_x(1), unique_y(2));
            
            % Check if the provided nodes match the expected rectangle corners
            provided_nodes = [node_1, node_2, node_3, node_4];
            expected_nodes = [node_bl, node_br, node_tr, node_tl];
            
            if ~is_members_match(expected_nodes, provided_nodes)
                disp(node_1)
                disp(node_2)
                disp(node_3)
                disp(node_4)
                error('The provided nodes do not correspond to the expected rectangle.');
            end
            
            % We are selecting the nodes from the passed nodes by using the index fo the artificial nodes as to seletc the nodes in the corretc order
            nodes = [node_1, node_2, node_3, node_4];
            
            obj = obj@Element4Nodes(nodes(node_bl.eq(nodes)), nodes(node_br.eq(nodes)), nodes(node_tr.eq(nodes)), nodes(node_tl.eq(nodes)), ["T"], material);
            obj.q_dot = q_dot;
            obj.colour = '#cccccc';

        end
        
        % Add boundaries to the tracked list
        function obj = apply_boundary(obj, boundary)
            obj.boundaries = {obj.boundaries{:}, boundary};
        end

        function T = get_stiffness_table(obj)
            boundary_tables = cellfun(@(x) x.get_stiffness_table(), obj.boundaries, 'UniformOutput', false);
            T = combine_tables(matrix_to_table(obj.get_stiffness_matrix(), obj.nodes, obj.dof), boundary_tables{:});
        end

        function T = get_loading_table(obj)
            boundary_tables = cellfun(@(x) x.get_loading_table(), obj.boundaries, 'UniformOutput', false);
            T = combine_tables(matrix_to_table(obj.get_loading_matrix(), obj.nodes, obj.dof, isload=true), boundary_tables{:});
        end

        function loading_matrix = get_loading_matrix(obj)
            node_loading = get_loading_matrix@Element4Nodes(obj);

            l = obj.node_2.x - obj.node_1.x;
            w = obj.node_4.y - obj.node_1.y;
            
            A = l * w;

            F = (obj.q_dot * A) / 4 * [1;1;1;1];


            loading_matrix = node_loading + F;
        end
        
        function stiffness_matrix = get_stiffness_matrix(obj)

            l = obj.node_2.x - obj.node_1.x;
            w = obj.node_4.y - obj.node_1.y;

            stiffness_matrix = (obj.material.k_x * w)/(6*l) * [
                2, -2, -1, 1;
                -2, 2, 1, -1;
                -1, 1, 2, -2;
                1, -1, -2, 2
            ] + (obj.material.k_y * l)/(6*w) * [
                2, 1, -1, -2;
                1, 2, -2, -1;
                -1, -2, 2, 1;
                -2, -1, 1, 2
            ];                
        end
        
        function states = get_solution_states(obj)
            states = [
                "T_1", get_relevant_dof(obj.node_1.dof, obj.node_1.solution, ["T",]), ...
                "T_2", get_relevant_dof(obj.node_2.dof, obj.node_2.solution, ["T",]), ...
                "T_3", get_relevant_dof(obj.node_3.dof, obj.node_3.solution, ["T",]), ...
                "T_4", get_relevant_dof(obj.node_4.dof, obj.node_4.solution, ["T",]), ...
            ];
        end

        function render_structure(obj)
            patch('Vertices', [obj.node_1.x, obj.node_1.y; obj.node_2.x, obj.node_2.y; obj.node_3.x, obj.node_3.y; obj.node_4.x, obj.node_4.y], 'Faces', [1, 2, 3, 4], 'FaceColor', obj.colour);
            disp(obj.boundaries)
            for i = 1:length(obj.boundaries)
                obj.boundaries{i}.render_structure()
            end
            obj.node_1.render_structure()
            obj.node_2.render_structure()
            obj.node_3.render_structure()
            obj.node_4.render_structure()
        end
        
    end
end
