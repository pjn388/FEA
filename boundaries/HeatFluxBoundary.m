classdef HeatFluxBoundary < Boundary
    properties
        q_flux  % Heat flux (W/m^2)
    end

    methods
        function obj = HeatFluxBoundary(node_a, node_b, q_flux)
            obj = obj@Boundary(node_a, node_b);
            obj.q_flux = q_flux;
            obj.colour = 'black';
        end
        
        function stiffness_matrix = get_stiffness_matrix(obj)
            stiffness_matrix = zeros(2, 2);
        end
        
        function loading_matrix = get_loading_matrix(obj)
            l = abs(sqrt((obj.node_a.x - obj.node_b.x)^2 + (obj.node_a.y - obj.node_b.y)^2));
            loading_matrix = (obj.q_flux * l) / 2 * ...
                [
                    1;
                    1
                ];
        end
        
    end
end
