% represents a constraint on the FEA mesh, is essentiall just a fancy named data holder
classdef Constraint
    properties
        node_1
        node_2
        dof
    end
    methods
        function obj = Constraint(node_1, node_2, dof)
            obj.node_1 = node_1;
            obj.node_2 = node_2;
            obj.dof = dof;
        end
    end
end
