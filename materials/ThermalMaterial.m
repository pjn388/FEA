classdef ThermalMaterial < Material
    properties
        k_x
        k_y
        k
    end

    methods
        function obj = ThermalMaterial(name, k_x, k_y)
            obj = obj@Material(name);
            obj.k_x = k_x;
            obj.k_y = k_y;
            obj.k = mean([k_x, k_y]);
        end
        function display(obj)
            fprintf('Material: %s\nk_x: %s\nk_y: %s\n', obj.name, obj.k_x, obj.k_y);
        end

    end
end