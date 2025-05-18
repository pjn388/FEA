classdef Material
    properties
        name
    end

    methods
        function obj = Material(name)
            obj.name = name;
        end

        % Anotehr helpfull display method for nodes
        function display(obj)
            disp("Material: "+obj.name)
        end
    end
end