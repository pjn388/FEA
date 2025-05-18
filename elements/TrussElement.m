% Generic truss element
classdef TrussElement < Element2Nodes
    properties
        A
        l
    end
    methods
        function obj = TrussElement(node_1, node_2, A, material)
            obj = obj@Element2Nodes(node_1, node_2, ["u", "v"], material);
            obj.A = A;
            obj.l = abs(sqrt((obj.node_1.x-obj.node_2.x)^2+(obj.node_1.y-obj.node_2.y)^2)); % calculate member length

        end

        function tranformation_matrix = get_tranformation_matrix(obj)
            % rotaion vlaues
            l_ij = (obj.node_2.x - obj.node_1.x) / obj.l; % cos alpha
            m_ij = (obj.node_2.y - obj.node_1.y) / obj.l; % sin alpha
            
            % rotaion matrix
            obj.T = [
                l_ij , m_ij,     0,    0;
                    0,    0,  l_ij, m_ij;
            ];

            tranformation_matrix = obj.T;
        end


        function shape_matrix = get_shape_matrix(obj, x, y)
            % this is the non rotated shape function for the member does nto account for the variation across the member
            shape_matrix = [-1/obj.l, 1/obj.l]*obj.get_tranformation_matrix();
        end

       function stiffness_matrix = get_stiffness_matrix(obj)
            T = obj.get_tranformation_matrix();
            % local stiffness matrix
            k_local = obj.A*obj.material.E/obj.l *...
            [
                1, -1;
                -1, 1
            ];
            % global stiffness matrix
            stiffness_matrix = T' * k_local * T;
        end

        % The relevent stress state of this member
        function states = get_stress_states(obj)
            states = ["Stress", obj.get_stress(0, 0)];
        end
    end
end
