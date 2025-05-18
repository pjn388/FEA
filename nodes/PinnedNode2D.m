classdef PinnedNode2D < RestrictedNode
    methods
        function obj = PinnedNode2D(x, y)
            obj = obj@RestrictedNode(x, y, ["u", "v"]);
        end
    end
end
