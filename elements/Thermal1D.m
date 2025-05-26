classdef Thermal1D < Element2Nodes & Thermal
    properties
        p
        A
        h_surround
        h_node_1
        h_node_2
        T_f
    end
    methods
        function obj = Thermal1D(node_1, node_2, material, A, p, h_surround, h_node_1, h_node_2, T_f)
            obj = obj@Thermal();
            obj = obj@Element2Nodes(node_1, node_2, ["T",], material);
            obj.A = A; % area of cross section
            obj.p = p; % perimeter of cross section
            obj.h_surround = h_surround;
            obj.h_node_1 = h_node_1;
            obj.h_node_2 = h_node_2;
            obj.T_f = T_f;
            obj.colour = "blue";
        end

        function T = get_stiffness_table(obj)
            T = matrix_to_table(obj.get_stiffness_matrix(), obj.nodes, obj.dof);
        end

        function T = get_loading_table(obj)
            T = matrix_to_table(obj.get_loading_matrix(), obj.nodes, obj.dof, isload=true);
        end

        function loading_matrix = get_loading_matrix(obj)
            node_loading = get_loading_matrix@Element2Nodes(obj);
            l = abs(sqrt((obj.node_1.x-obj.node_2.x)^2+(obj.node_1.y-obj.node_2.y)^2)); % calculate member length

            F = (obj.h_surround*obj.p*l*obj.T_f)/2*[1;1] + [obj.h_node_1*obj.A*obj.T_f; 0] + [0; obj.h_node_2*obj.A*obj.T_f];

            loading_matrix = node_loading + F;
        end
        
        function stiffness_matrix = get_stiffness_matrix(obj)
            l = abs(sqrt((obj.node_1.x-obj.node_2.x)^2+(obj.node_1.y-obj.node_2.y)^2)); % calculate member length

            stiffness_matrix = (obj.material.k*obj.A)/l*[1, -1; -1, 1] + (obj.h_surround*obj.p*l)/6 * [2, 1; 1, 2] + [obj.h_node_1*obj.A, 0; 0, 0] + [0, 0; 0, obj.h_node_2*obj.A];
        end
        
        function states = get_solution_states(obj)
            states = [
                "T_1", get_relevant_dof(obj.node_1.dof, obj.node_1.solution, ["T",]), ...
                "T_2", get_relevant_dof(obj.node_2.dof, obj.node_2.solution, ["T",]), ...
            ];
        end

        function render_structure(obj)
            line([obj.node_1.x, obj.node_2.x], [obj.node_1.y, obj.node_2.y], 'Color', obj.colour);
            obj.node_1.render_structure()
            obj.node_2.render_structure()
        end

    end
end
