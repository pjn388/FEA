classdef Material
    properties
        name
    end

    methods
        function obj = Material(name)
            obj.name = name;
        end

        % Another helpfull display method for materials
        function display(obj)
            disp("Material: "+obj.name)
        end
    end
end