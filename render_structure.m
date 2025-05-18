function [legendHandles, legendLabels] = render_structure(elements, nodes, isStressed, legendHandles, legendLabels, name)

    for element_index = 1:length(elements)
        elements{element_index}.render_structure()
        
    end

end