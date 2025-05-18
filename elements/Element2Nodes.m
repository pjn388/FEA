
% abstract class for 2 node elements
classdef Element2Nodes < Element2D

    properties
        node_1
        node_2
    end

    methods
        function obj = Element2Nodes(node_1, node_2, dof, material)
            obj = obj@Element2D({node_1, node_2}, dof, material);
            obj.node_1 = node_1;
            obj.node_2 = node_2;
        end
    end
end
