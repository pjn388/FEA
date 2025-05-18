classdef ElasticMaterial < Material
    properties
        E
    end

    methods
        function obj = ElasticMaterial(name, E)
            obj = obj@Material(name);
            obj.E = E;
        end
        function display(obj)
            fprintf('Material: %s\nE: %s\n', obj.name, obj.E);
        end
    end
end