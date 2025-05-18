% Represents a base 2D element
classdef Boundary
    properties
        node_a
        node_b
        colour
    end
    
    methods
        function obj = Boundary(node_a, node_b)
            obj.node_a = node_a;
            obj.node_b = node_b;
        end

        % make relevent matrix tables
        function T = get_stiffness_table(obj)
            T = matrix_to_table(obj.get_stiffness_matrix(), {obj.node_a, obj.node_b}, ["T"]);
        end
        function T = get_loading_table(obj)
            T = matrix_to_table(obj.get_loading_matrix(), {obj.node_a, obj.node_b}, ["T"], isload=true);
        end
        function render_structure(obj)
            plot([obj.node_a.x, obj.node_b.x], [obj.node_a.y, obj.node_b.y], 'Color', obj.colour, 'LineWidth', 2)
        end
    end
end

