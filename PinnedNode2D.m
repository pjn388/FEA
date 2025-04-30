% Just a node but with a different name
classdef PinnedNode2D < Node2D
    methods
        function obj = PinnedNode2D(x, y)
            obj = obj@Node2D(x, y);
            obj.constrained_dof = ["u", "v"];
        end
    end
end
