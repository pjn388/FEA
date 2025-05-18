% Abstract class for restricted nodes ie nodes with a restricted dof in the solution matrix
classdef RestrictedNode < Node2D
    methods
        function obj = RestrictedNode(x, y, constrained_dof)
            obj = obj@Node2D(x, y);
            obj.constrained_dof = constrained_dof;
        end
        function obj = apply_constraint(obj)
            for i = 1:length(obj.dof)
                if any(strcmp(obj.dof(i),obj.constrained_dof))
                    obj.solution(i) = 0;
                end
            end
        end
    end
end
