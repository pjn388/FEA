classdef ElasticMaterial < Material
    properties
        E
    end

    methods
        function obj = ElasticMaterial(name, E)
            obj = obj@Material(name);
            obj.E = E;
        end
    end
end