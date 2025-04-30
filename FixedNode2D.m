% Just a node but with a different name
classdef FixedNode2D < Node2D
    methods
        function obj = FixedNode2D(x, y)
            obj = obj@Node2D(x, y);
            obj.constrained_dof = ["u", "v", "theta"];
        end
    end
end
