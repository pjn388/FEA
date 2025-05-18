% Just a node but with a different name
classdef FixedNode2D < RestrictedNode
    methods
        function obj = FixedNode2D(x, y)
            obj = obj@RestrictedNode(x, y, ["u", "v", "theta"]);
        end
    end
end
