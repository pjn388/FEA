
% abstract class for 2 node elements
classdef Element4Nodes < Element2D

    properties
        node_1
        node_2
        node_3
        node_4
    end

    methods
        function obj = Element4Nodes(node_1, node_2, node_3, node_4, dof, material)
            obj = obj@Element2D({node_1, node_2, node_3, node_4}, dof, material);
            obj.node_1 = node_1;
            obj.node_2 = node_2;
            obj.node_3 = node_3;
            obj.node_4 = node_4;
        end
    end
end
