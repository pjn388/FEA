% This is just a 2D node
% Nodes are labeled with a uuid so they are unique
classdef Node2D < handle
    properties (Access = private) % ensure these cannot be public accessed as they may not be in a correct state unless accessed by the getter
        solved = false
    end
    properties
        x
        y
        dof
        loading
        solution
        uuid
        constrained_dof
        colour
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
            obj.colour = 'black';
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
            obj.solved = true;
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

        function tf = eq(obj1, obj2)
            % Overriding the eq method to compare Node2D objects based on x and y values
            if ~isa(obj2, 'Node2D')
                tf = false(size(obj1)); % Return a logical array of the same size as obj1
                return;
            end
            
            % Initialize the output logical array
            tf = false(size(obj2)); % Size of obj2 since we are comparing obj1 to each element of obj2
            
            % Check if obj1 is a single instance
            if numel(obj1) == 1
                % Compare obj1 with each element of obj2
                for i = 1:numel(obj2)
                    tf(i) = (obj1.x == obj2(i).x) && (obj1.y == obj2(i).y);
                end
            else
                % If obj1 is an array, handle it accordingly (optional)
                error('obj1 should be a single instance of Node2D for this comparison.');
            end
        end
        
        % Anotehr helpfull display method for nodes
        function display(obj)
            disp(obj.display_())
        end
        function render_structure(obj)
            plot(obj.x, obj.y, "o", 'MarkerFaceColor', obj.colour, 'MarkerEdgeColor', obj.colour, 'MarkerSize', 8);

                if ~obj.solved
                    return;
                end

                % Initialize an empty string
                prettyString = sprintf('Node: %s\n', obj.uuid);

                % Loop through the arrays to create the formatted string
                for i = 1:length(obj.dof)
                    prettyString = prettyString + obj.dof(i) + ": " + num2str(obj.solution(i)) + newline;
                end


                text(obj.x+0.004, obj.y+0.004, prettyString, 'FontSize', 8, 'HorizontalAlignment', 'center');


        end
    end
end