% Generic truss element
classdef TrussElement < Element2D
    properties
        A
        E
        l
    end
    methods
        function obj = TrussElement(node_1, node_2, A, E)
            obj = obj@Element2D(node_1, node_2, ["u", "v"]);
            obj.A = A;
            obj.E = E;
            obj.l = abs(sqrt((node_1.x-node_2.x)^2+(node_1.y-node_2.y)^2)); % calculate member length
        end

       function stiffness_matrix = get_stiffness_matrix(obj)
            % rotaion vlaues
            l_ij = (obj.node_2.x - obj.node_1.x) / obj.l; % cos alpha
            m_ij = (obj.node_2.y - obj.node_1.y) / obj.l; % sin alpha
            
            % rotaion matrix
            T = [
                l_ij , m_ij,     0,    0;
                    0,    0,  l_ij, m_ij;
            ];
            
            % local stiffness matrix
            k_local = obj.A*obj.E/obj.l *...
            [
                1, -1;
                -1, 1
            ];
            % global stiffness matrix
            stiffness_matrix = T' * k_local * T;
        end
    end
end
