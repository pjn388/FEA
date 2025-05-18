% Represents a base 2D element
classdef Element2D
    properties (Access = private) % ensure these cannot be public accessed as they may not be in a correct state unless accessed by the getter
        stiffness_matrix
        loading_matrix
        shape_matrix
        solution_matrix
    end

    properties
        nodes
        dof
        material
        T
    end
    
    methods
        function obj = Element2D(nodes, dof, material)
            obj.nodes = nodes;
            obj.dof = dof;
            obj.material = material;

            for i = 1:length(nodes)
                % update node dof so the nodes know how many dof they have based upon the elements that use them
                nodes{i}.dof = unique([nodes{i}.dof, obj.dof]);
                % update node loading based upon dof, we have no loading untill an external loading is applied
                nodes{i}.loading = zeros(1, length(nodes{i}.dof));
            end
        end
        
        % helper function to make displaying an element a usefull experience
        function display(obj)
            % i hate nested function defs but im feeling lazy
            function displayNode(node)
                fprintf('  %s: %s\n', class(node), node.uuid);
            end
            fprintf('%s:\n', class(obj));
            for i = 1:length(obj.nodes)
                displayNode(obj.nodes{i});
            end
            fprintf('  Stiffness Matrix:\n');
            disp(obj.get_stiffness_matrix());
        end
        
        % getters to ensure that calculations are performed before accessing values
        function tranformation_matrix = get_tranformation_matrix(obj)
            tranformation_matrix = obj.T;
        end
        function shape_matrix = get_shape_matrix(obj, x, y) % this is overwritten by the child classes based upon the element type
            shape_matrix = obj.shape_matrix;
        end
        function stiffness_matrix = get_stiffness_matrix(obj) % this is overwritten by the child classes based upon the element type
            stiffness_matrix = obj.stiffness_matrix;
        end
        function loading_matrix = get_loading_matrix(obj)
            
            arrayout = zeros(length(obj.dof)*length(obj.nodes), 1);
            
            for i = 1:length(obj.nodes)
                % assing the correct section of the out matrix to the correct setion of the nodes loading matrix
                % ... the line below is EXACTLY why normal languages start indexing at 0
                node_n_loading = get_relevant_dof(obj.nodes{i}.dof, obj.nodes{i}.loading, obj.dof);
                
                % Matlab indexing is the dumbest thing ever hence this logic to explain the simplest computer science concept and a headache of off by one error
                % i is the index of the current node 
                % we have an out array of n*len(dof) this is n blocks of len(dof)
        
                % we want to insert node_n_loading at its block in this array
        
                % the block indexes will be len(dof)*i => this is assuming 0 index
                % the end of the block is start+len(dof)
                % we need to add 1 to both of these values cos of matlab 1 indexing
                % we need to remove 1 from i cos matlab 1 indexing
                % therefore
                % block index starts are len(dof)*(i-1)+1
                % block end index is len(dof)*(i)+1


                arrayout(length(obj.dof)*(i-1)+1:length(obj.dof)*(i)) = node_n_loading(:);
            end
                            
            obj.loading_matrix = arrayout;
            loading_matrix = obj.loading_matrix;
        end
        function solution_matrix = get_solution_matrix(obj)
            
            arrayout = zeros(length(obj.dof)*length(obj.nodes), 1);
            for i = 1:length(obj.nodes)
                obj.nodes{i}.apply_constraint(); % apply the constraints of a RestrictedNode

                % assing the correct section of the out matrix to the correct setion of the nodes solution matrix
                node_n_solution = get_relevant_dof(obj.nodes{i}.dof, obj.nodes{i}.solution, obj.dof);
                arrayout(length(obj.dof)*(i-1)+1:length(obj.dof)*(i)) = node_n_solution(:);


            end

            obj.solution_matrix = arrayout;
            solution_matrix = obj.solution_matrix;
        end

        % make relevent matrix tables
        function T = stiffness_table(obj)
            T = matrix_to_table(obj.get_stiffness_matrix(), obj.nodes, obj.dof);
        end
        function T = loading_table(obj)
            T = matrix_to_table(obj.get_loading_matrix(), obj.nodes, obj.dof, isload=true);
        end

        function stress = get_stress(obj, x, y)
            stress = obj.material.E*obj.get_shape_matrix(x, y)*obj.get_solution_matrix();
        end
    end
end

% gets the relevent dof's values from an array of dof's and their values
function relevant_values = get_relevant_dof(dofs, values, relevant_dofs)
    relevant_values = zeros(length(relevant_dofs), 1);
    for i = 1:length(relevant_dofs)
        dof_index = find(strcmp(dofs, relevant_dofs{i}));
        if ~isempty(dof_index)
            relevant_values(i) = values(dof_index);
        end
    end
end