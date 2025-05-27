classdef FixedTemperatureBoundary < Boundary
    properties
        T_fixed  % Fixed temperature (°C or K)
    end

    methods
        function obj = FixedTemperatureBoundary(node_a, node_b, T_fixed)
            obj = obj@Boundary(node_a, node_b);
            obj.T_fixed = T_fixed;
            obj.colour = 'red';  % You can choose a different color if needed
        end
        
        % These mattricies are kinda irrelevent for fixed temp boundaries as these are applied later
        function stiffness_matrix = get_stiffness_matrix(obj)
            stiffness_matrix = zeros(2, 2);
        end
        
        function loading_matrix = get_loading_matrix(obj)
            l = abs(sqrt((obj.node_a.x - obj.node_b.x)^2 + (obj.node_a.y - obj.node_b.y)^2)); % calculate member length
            loading_matrix = (sym("q_flux")*l)/2 * [1;1];
        end
    end
end
