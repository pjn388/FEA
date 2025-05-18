
% standard frame element represents a combined truss and beam element
classdef FrameElement < Element2Nodes
    properties
        A
        l
        I
        r
    end
    methods
        function obj = FrameElement(node_1, node_2, A, material, I, r)
            obj = obj@Element2Nodes(node_1, node_2, ["u", "v", "theta"], material);
            obj.A = A;
            obj.l = abs(sqrt((obj.node_1.x-obj.node_2.x)^2+(obj.node_1.y-obj.node_2.y)^2)); % calculate member length
            obj.I = I;
            obj.r = r; % this is the distance form neutral axis to the beam top/bottom
        end

        function shape_matrix = get_shape_matrix(obj, x, y)
            l = obj.l;
            shape_matrix = [-1/l, -y/l^3*(12*x-6*l), -y/l^2*(6*x-4*l), 1/l, y/l^3*(12*x-6*l), -y/l^2*(6*x-2*l)]*obj.get_tranformation_matrix();
        end

        function tranformation_matrix = get_tranformation_matrix(obj)
            % cosines and sines for rotation matrix
            l_ij = (obj.node_2.x - obj.node_1.x) / obj.l; % cos alpha
            m_ij = (obj.node_2.y - obj.node_1.y) / obj.l; % sin alpha
            
            % Transformation matrix, you spin me round
            obj.T =[
                l_ij ,m_ij,0,0    ,0   ,0;
                -m_ij,l_ij,0,0    ,0   ,0;
                0    ,0   ,1,0    ,0   ,0;
                0    ,0   ,0,l_ij ,m_ij,0;
                0    ,0   ,0,-m_ij,l_ij,0;
                0    ,0   ,0,0    ,0   ,1 ...
            ];

            tranformation_matrix = obj.T;
        end
        
        function stiffness_matrix = get_stiffness_matrix(obj)  
            T = obj.get_tranformation_matrix();   
            % saving typing
            A = obj.A;
            E = obj.material.E;
            l = obj.l;
            I = obj.I;
            
            % Local stiffness matrix
            k_local =[
                E*A/l , 0          , 0         , -E*A/l, 0          , 0         ;
                0     , 12*E*I/l^3 , 6*E*I/l^2 , 0     , -12*E*I/l^3, 6*E*I/l^2 ;
                0     , 6*E*I/l^2  , 4*E*I/l   , 0     , -6*E*I/l^2 , 2*E*I/l   ;
                -E*A/l, 0          , 0         , E*A/l , 0          , 0         ;
                0     , -12*E*I/l^3, -6*E*I/l^2, 0     , 12*E*I/l^3 , -6*E*I/l^2;
                0     , 6*E*I/l^2  , 2*E*I/l   , 0     , -6*E*I/l^2 , 4*E*I/l ...
            ];
            
            % Global stiffness matrix
            stiffness_matrix = T' * k_local * T;
        end
        
        % The areas of concern for stresses in the element
        function states = get_stress_states(obj)

            states = [...
                sprintf("node(%s) top", obj.node_1.uuid) , obj.get_stress(0, obj.r),...
                sprintf("node(%s) bottom", obj.node_1.uuid) , obj.get_stress(0, -obj.r),...
                sprintf("node(%s) top", obj.node_2.uuid) , obj.get_stress(obj.l, obj.r),...
                sprintf("node(%s) bottom", obj.node_2.uuid) , obj.get_stress(obj.l, -obj.r),...
            ];
        end

    end
end
