% Generic truss element
classdef ThermalTriangleElement < Element3Nodes
    properties
        q_dot
        boundaries cell
    end
    methods
        function obj = ThermalTriangleElement(node_1, node_2, node_3, material, q_dot)
            obj = obj@Element3Nodes(node_1, node_2, node_3, ["T",], material);
            obj.q_dot = q_dot;
        end
        
        % add boundaries to the tracked list
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
            node_loading = get_loading_matrix@Element3Nodes(obj);

            X_i = obj.node_1.x;
            Y_i = obj.node_1.y;
            X_j = obj.node_2.x;
            Y_j = obj.node_2.y;
            X_k = obj.node_3.x;
            Y_k = obj.node_3.y;
            A = (1/2)*abs(X_i*(Y_j-Y_k)+X_j*(Y_k-Y_i)+X_k*(Y_i-Y_j));

            F = (obj.q_dot*A)/3 * [1;1;1];

            loading_matrix = node_loading + F;
        end
        

       function stiffness_matrix = get_stiffness_matrix(obj)

        X_i = obj.node_1.x;
        Y_i = obj.node_1.y;
        X_j = obj.node_2.x;
        Y_j = obj.node_2.y;
        X_k = obj.node_3.x;
        Y_k = obj.node_3.y;

        beta_i = Y_j - Y_k;
        beta_j = Y_k - Y_i;
        beta_k = Y_i - Y_j;

        sigma_i = X_k - X_j;
        sigma_j = X_i - X_k;
        sigma_k = X_j - X_i;

        A = (1/2)*abs(X_i*(Y_j-Y_k)+X_j*(Y_k-Y_i)+X_k*(Y_i-Y_j));



        stiffness_matrix = ...
            (obj.material.k_x/(4*A))*...
            [
                beta_i^2, beta_i*beta_j, beta_i*beta_k;
                beta_i*beta_j, beta_j^2, beta_j*beta_k;
                beta_i*beta_k, beta_j*beta_k, beta_k^2
            ] + ...
            (obj.material.k_y/(4*A))*...
            [
                sigma_i^2, sigma_i*sigma_j, sigma_i*sigma_k;
                sigma_i*sigma_j, sigma_j^2, sigma_j*sigma_k;
                sigma_i*sigma_k, sigma_j*sigma_k, sigma_k^2
            ];

        end
        
        function states = get_solution_states(obj)
            states = [
                "T_1", get_relevant_dof(obj.node_1.dof, obj.node_1.solution, ["T",]), ...
                "T_2", get_relevant_dof(obj.node_2.dof, obj.node_2.solution, ["T",]), ...
                "T_3", get_relevant_dof(obj.node_3.dof, obj.node_3.solution, ["T",]), ...
            ];
        end
        
    end
end
