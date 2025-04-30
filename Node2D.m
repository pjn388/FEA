% This is just a 2D node
% Nodes are labeled with a uuid so they are unique
classdef Node2D < handle
    properties
        x
        y
        dof
        loading
        displacement
        uuid
        constrained_dof
    end

    methods
        function obj = Node2D(x, y)
            obj.x = x;
            obj.y = y;
            obj.dof = [];
            obj.loading = [];
            obj.displacement = [];
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

        function obj = apply_displacement(obj, dofs, displacements)
            % Iterate through the dofs and apply the corresponding displacement state
            for i = 1:length(dofs)
                idx = find(obj.dof == dofs(i), 1);
                if ~isempty(idx)
                    if isempty(obj.displacement)
                        obj.displacement = zeros(1, length(obj.dof));
                    end
                    obj.displacement(idx) = obj.displacement(idx) + displacements(i);
                else
                    error('Cannot apply a displacement for dof '+dofs(1)+' as that dof does not exist for this node.')
                end
            end
            obj = obj;
        end
        
        % Anotehr helpfull display method for nodes
        function display(obj)
            className = class(obj);

            if isempty(obj.loading)
                loadingStr = '[]';
            else
                loadingStr = strjoin(arrayfun(@num2str, obj.loading, 'UniformOutput', false), ', ');
            end
            if isempty(obj.displacement)
                displacementStr = '[]';
            else
                displacementStr = strjoin(arrayfun(@num2str, obj.displacement, 'UniformOutput', false), ', ');
            end
            % btw i hate matlab string bashing
            disp(strjoin([className, '(',obj.uuid,'): x = ', num2str(obj.x), ', y = ', num2str(obj.y), ', dof = [',strjoin(string(obj.dof), ", "), '], loading = [', loadingStr, '], displacement = [', displacementStr, ']'], ''));
        end
    end
end