classdef ConvectionBoundary < Boundary
    properties
        h
        T_f
        l
    end

    methods
        function obj = ConvectionBoundary(node_a, node_b, h, T_f)
            obj = obj@Boundary(node_a, node_b);
            obj.h = h;
            obj.T_f = T_f;
            obj.l = abs(sqrt((obj.node_a.x-obj.node_b.x)^2+(obj.node_a.y-obj.node_b.y)^2)); % calculate member length
            obj.colour = 'green';
        end
        
        function stiffness_matrix = get_stiffness_matrix(obj) % this is overwritten by the child classes based upon the element type
            stiffness_matrix = (obj.h*obj.l)/6 * ...
                [
                    2, 1;
                    1, 2
                ];
        end
        function loading_matrix = get_loading_matrix(obj)
            loading_matrix = (obj.h*obj.T_f*obj.l)/2 * ...
                [
                    1;
                    1
                ];
        end
    end
end


