classdef TermalMaterial < Material
    properties
        k_x
        k_y
    end

    methods
        function obj = TermalMaterial(name, k_x, k_y)
            obj = obj@Material(name);
            obj.k_x = k_x;
            obj.k_y = k_y;
        end
        function display(obj)
            fprintf('Material: %s\nk_x: %s\nk_y: %s\n', obj.name, obj.k_x, obj.k_y);
        end

    end
end