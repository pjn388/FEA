% This is just a 2D node
% Nodes are labeled with a uuid so they are unique
classdef Node2D < handle
    properties
        x
        y
        dof
        loading
        solution
        uuid
        constrained_dof
    end

    methods
        function obj = Node2D(x, y)
            obj.x = x;
            obj.y = y;
            obj.dof = [];
            obj.loading = [];
            obj.solution = [];
            obj.uuid = extractBefore(string(java.util.UUID.randomUUID), 9); % generate a random uuid for each node. thx java i guess?
            obj.constrained_dof = [];
        end
        
        function obj = apply_loading(obj, dofs, loadings)
            % Iterate through the dofs and apply the corresponding loading state
            for i = 1:length(dofs)
                idx = find(obj.dof == dofs(i), 1);
                if ~isempty(idx)
                    if isempty(obj.loading)
                        obj.loading = zeros(1, length(obj.dof));
                    end
                    obj.loading(idx) = obj.loading(idx) + loadings(i);
                else
                    error('Cannot apply a loading for dof '+dofs(1)+' as that dof does not exist for this node.')
                end
            end
            obj = obj;
        end

        function obj = set_solution(obj, dofs, solutions)
            % Iterate through the dofs and apply the corresponding solution state
            for i = 1:length(dofs)
                idx = find(obj.dof == dofs(i), 1);
                if ~isempty(idx)
                    if isempty(obj.solution)
                        obj.solution = zeros(1, length(obj.dof));
                    end
                    obj.solution(idx) = solutions(i);
                else
                    error('Cannot apply a solution for dof '+dofs(1)+' as that dof does not exist for this node.')
                end
            end
            obj = obj;
        end

        function obj = apply_constraint(obj) % Node interface function
        end

        function out = display_(obj)
            className = class(obj);
    
            if isempty(obj.loading)
                loadingStr = '[]';
            else
                loadingStr = strjoin(arrayfun(@num2str, obj.loading, 'UniformOutput', false), ', ');
            end
            if isempty(obj.solution)
                solutionStr = '[]';
            else
                solutionStr = strjoin(arrayfun(@num2str, obj.solution, 'UniformOutput', false), ', ');
            end
            % btw i hate matlab string bashing
            out = strjoin([className, '(',obj.uuid,'): x = ', num2str(obj.x), ', y = ', num2str(obj.y), ', dof = [',strjoin(string(obj.dof), ", "), '], loading = [', loadingStr, '], solution = [', solutionStr, ']'], '');
        end
        
        % Anotehr helpfull display method for nodes
        function display(obj)
            disp(obj.display_())
        end
    end
end