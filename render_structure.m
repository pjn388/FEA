% Renders any compatable mesh


% TODO: Clean this function up to be neeter and not such an ugnly mess

function [legendHandles, legendLabels] = render_structure(elements, nodes, isStressed, legendHandles, legendLabels)
    % Node Colours based on Class
    fixedNodeColour = 'r'; % Red for FixedNode
    pinnednodeColour = 'c';
    nodeColour = 'b'; % Blue for Node2D

    % Element Colours based on Class
    frameColour = 'g'; % Green for FrameElement
    trussColour = 'm'; % Magenta for TrussElement

    % Store handles for legend
    fixedNodeHandle = [];
    PinnedNodeHandle = [];
    nodeHandle = [];
    frameHandle = [];
    trussHandle = [];
    
    nodeHandleStressed = [];
    frameHandleStressed = [];
    trussHandleStressed = [];

    nodePositions = zeros(length(nodes), 2);
    textHandles = cell(length(nodes), 1);
    elementTextHandles = cell(length(elements), 1);
    
    % render all the nodes
    if isStressed
        affix = 'Stressed';
        style = '--';
    else
        affix = '';
        style = '-';
    end
    for i = 1:length(nodes)
        node = nodes{i};
        [x, y] = get_node_xy(node, isStressed);
        % Determine node colour based on class
        if isa(node, 'FixedNode2D')
            colour = fixedNodeColour;
            marker = 's'; % Square marker for fixed nodes
            if isempty(fixedNodeHandle)
                fixedNodeHandle = plot(x, y, marker, 'MarkerFaceColor', colour, 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
            else
                plot(x, y, marker, 'MarkerFaceColor', colour, 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
            end
        elseif isa(node, 'PinnedNode2D')
            colour = pinnednodeColour;
            marker = 's'; % square marker for pinned nodes
            if isempty(nodeHandle)
                PinnedNodeHandle = plot(x, y, marker, 'MarkerFaceColor', colour, 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
            else
                plot(x, y, marker, 'MarkerFaceColor', colour, 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
            end
        elseif isa(node, 'Node2D')
            colour = nodeColour;
            marker = 'o'; % Circle marker for regular nodes
            if isStressed
                 if isempty(nodeHandleStressed)
                    nodeHandleStressed = plot(x, y, marker, 'MarkerFaceColor', colour, 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
                else
                    plot(x, y, marker, 'MarkerFaceColor', colour, 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
                end
            else
                if isempty(nodeHandle)
                    nodeHandle = plot(x, y, marker, 'MarkerFaceColor', colour, 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
                else
                    plot(x, y, marker, 'MarkerFaceColor', colour, 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
                end
            end
        else
            % TODO: implement some hash funciton to colour generator so unique members are unique colours
            colour = 'k'; % Black for unknown node types
            marker = '*';
            plot(x, y, marker, 'MarkerFaceColor', colour, 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
        end

        nodePositions(i, :) = [x, y];

        % Initial text position
        x_text = x + 0.05;
        y_text = y + 0.05;
        textHandles{i} = text(x_text, y_text, sprintf('Node %s (%s) - %s', node.uuid, strjoin(node.dof, ', '), affix), 'FontSize', 8);
    end

    % Adjust text positions to avoid overlap, this isnt fun and isnt perfect but it will do
    for i = 1:length(nodes)
        for j = i+1:length(nodes)
            pos1 = get(textHandles{i}, 'Position');
            pos2 = get(textHandles{j}, 'Position');

            % Check if texts are too close
            if norm(pos1(1:2) - pos2(1:2)) < 0.5
                % Adjust position of the second text
                pos2_new = pos2;
                pos2_new(2) = pos2_new(2) - 0.05; % Move down

                set(textHandles{j}, 'Position', pos2_new);
            end
        end
    end


    % render elements
    for i = 1:length(elements)
        element = elements{i};
        
        % Get node coordinates
        [x1, y1] = get_node_xy(element.node_1, isStressed);
        [x2, y2] = get_node_xy(element.node_2, isStressed);
        mid_x = (x1 + x2) / 2;
        mid_y = (y1 + y2) / 2;

        % Determine element colour based on class
        if isa(element, 'FrameElement')
            colour = frameColour;
            if isStressed
                if isempty(frameHandleStressed)
                    frameHandleStressed = plot([x1, x2], [y1, y2], 'Color', colour, 'LineWidth', 2, 'LineStyle', style);
                else
                    plot([x1, x2], [y1, y2], 'Color', colour, 'LineWidth', 2, 'LineStyle', style);
                end
            else
                if isempty(frameHandle)
                    frameHandle = plot([x1, x2], [y1, y2], 'Color', colour, 'LineWidth', 2, 'LineStyle', style);
                else
                    plot([x1, x2], [y1, y2], 'Color', colour, 'LineWidth', 2, 'LineStyle', style);
                end
            end
        elseif isa(element, 'TrussElement')
            colour = trussColour;
             if isStressed
                if isempty(trussHandleStressed)
                    trussHandleStressed = plot([x1, x2], [y1, y2], 'Color', colour, 'LineWidth', 2, 'LineStyle', style);
                else
                    plot([x1, x2], [y1, y2], 'Color', colour, 'LineWidth', 2, 'LineStyle', style);
                end
            else
                if isempty(trussHandle)
                    trussHandle = plot([x1, x2], [y1, y2], 'Color', colour, 'LineWidth', 2, 'LineStyle', style);
                else
                    plot([x1, x2], [y1, y2], 'Color', colour, 'LineWidth', 2, 'LineStyle', style);
                end
            end
        else
            colour = 'k';
            plot([x1, x2], [y1, y2], 'Color', colour, 'LineWidth', 2, 'LineStyle', style);
        end

        if isStressed
            stress_info = element.get_stress_states();
            stress_text = '';
            for k = 1:2:length(stress_info)
                stress_name = stress_info{k};
                stress_value = stress_info{k+1};
                stress_display = render_stress(double(string(stress_value)));
                stress_text = sprintf('%s%s: %s\n', stress_text, stress_name, stress_display);
            end
            elementTextHandles{i} = text(mid_x, mid_y, stress_text, 'FontSize', 8, 'HorizontalAlignment', 'center');
        end
    end

    if ~isempty(fixedNodeHandle)
        legendHandles = [legendHandles, fixedNodeHandle];
        legendLabels = [legendLabels, {'Fixed Node'}];
    end
    if ~isempty(PinnedNodeHandle)
        legendHandles = [legendHandles, PinnedNodeHandle];
        legendLabels = [legendLabels, {'Pinned Node'}];
    end
    if ~isempty(nodeHandle)
        legendHandles = [legendHandles, nodeHandle];
        legendLabels = [legendLabels, {'Node'}];
    end
    if ~isempty(frameHandle)
        legendHandles = [legendHandles, frameHandle];
        legendLabels = [legendLabels, {'Frame Element'}];
    end
    if ~isempty(trussHandle)
        legendHandles = [legendHandles, trussHandle];
        legendLabels = [legendLabels, {'Truss Element'}];
    end
    if ~isempty(nodeHandleStressed)
        legendHandles = [legendHandles, nodeHandleStressed];
        legendLabels = [legendLabels, {'Node Stressed'}];
    end
    if ~isempty(frameHandleStressed)
        legendHandles = [legendHandles, frameHandleStressed];
        legendLabels = [legendLabels, {'Frame Element Stressed'}];
    end
    if ~isempty(trussHandleStressed)
        legendHandles = [legendHandles, trussHandleStressed];
        legendLabels = [legendLabels, {'Truss Element Stressed'}];
    end
    
    [~, uniqueIdx] = unique(legendLabels, 'stable');
    legendHandles = legendHandles(uniqueIdx);
    legendLabels = legendLabels(uniqueIdx);
    legend(legendHandles, legendLabels, 'Location', 'northwest');

    title('Structure Visualization');
    xlabel('X Coordinate (m)');
    ylabel('Y Coordinate (m)');
    axis equal;
    grid on;
end

function [x, y] = get_node_xy(node, isStressed)
    x = node.x;
    y = node.y;

    if isempty(node.displacement) || isempty(node.dof) || ~isStressed
        return;
    end

    dof_x_index = find(strcmp(node.dof, 'u'));
    dof_y_index = find(strcmp(node.dof, 'v'));

    if ~isempty(dof_x_index) && dof_x_index <= length(node.displacement)
        x = x + node.displacement(dof_x_index);
    end

    if ~isempty(dof_y_index) && dof_y_index <= length(node.displacement)
        y = y + node.displacement(dof_y_index);
    end
end

function stress_str = render_stress(stress_pa)
    abs_stress = abs(stress_pa);
    if abs_stress >= 1e9
        stress_str = sprintf('%.2f GPa', stress_pa / 1e9);
    elseif abs_stress >= 1e6
        stress_str = sprintf('%.2f MPa', stress_pa / 1e6);
    elseif abs_stress >= 1e3
        stress_str = sprintf('%.2f kPa', stress_pa / 1e3);
    else
        stress_str = sprintf('%.2f Pa', stress_pa);
    end
end
