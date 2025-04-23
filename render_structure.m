% Renders any compatable mesh

function render_structure(elements, nodes, affix, style)
    % Node Colours based on Class
    fixedNodeColour = 'r'; % Red for FixedNode
    nodeColour = 'b'; % Blue for Node2D

    % Element Colours based on Class
    frameColour = 'g'; % Green for FrameElement
    trussColour = 'm'; % Magenta for TrussElement

    % Store handles for legend
    fixedNodeHandle = [];
    nodeHandle = [];
    frameHandle = [];
    trussHandle = [];

    nodePositions = zeros(length(nodes), 2);
    textHandles = cell(length(nodes), 1);

    % render all the nodes
    for i = 1:length(nodes)
        node = nodes{i};
        % Determine node colour based on class
        if isa(node, 'FixedNode2D')
            colour = fixedNodeColour;
            marker = 's'; % Square marker for fixed nodes
            if isempty(fixedNodeHandle)
                fixedNodeHandle = plot(node.x, node.y, marker, 'MarkerFaceColor', colour, 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
            else
                plot(node.x, node.y, marker, 'MarkerFaceColor', colour, 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
            end
        elseif isa(node, 'Node2D')
            colour = nodeColour;
            marker = 'o'; % Circle marker for regular nodes
            if isempty(nodeHandle)
                nodeHandle = plot(node.x, node.y, marker, 'MarkerFaceColor', colour, 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
            else
                plot(node.x, node.y, marker, 'MarkerFaceColor', colour, 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
            end
        else
            % TODO: implement some hash funciton to colour generator so unique members are unique colours
            colour = 'k'; % Black for unknown node types
            marker = '*';
            plot(node.x, node.y, marker, 'MarkerFaceColor', colour, 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
        end

        nodePositions(i, :) = [node.x, node.y];

        % Initial text position
        x_text = node.x + 0.05;
        y_text = node.y + 0.05;
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
        x1 = element.node_1.x;
        y1 = element.node_1.y;
        x2 = element.node_2.x;
        y2 = element.node_2.y;

        % Determine element colour based on class
        if isa(element, 'FrameElement')
            colour = frameColour;
            if isempty(frameHandle)
                frameHandle = plot([x1, x2], [y1, y2], 'Color', colour, 'LineWidth', 2, 'LineStyle', style);
            else
                plot([x1, x2], [y1, y2], 'Color', colour, 'LineWidth', 2, 'LineStyle', style);
            end
        elseif isa(element, 'TrussElement')
            colour = trussColour;
            if isempty(trussHandle)
                trussHandle = plot([x1, x2], [y1, y2], 'Color', colour, 'LineWidth', 2, 'LineStyle', style);
            else
                plot([x1, x2], [y1, y2], 'Color', colour, 'LineWidth', 2, 'LineStyle', style);
            end
        else
            colour = 'k';
            plot([x1, x2], [y1, y2], 'Color', colour, 'LineWidth', 2, 'LineStyle', style);
        end
    end

    % Add legend. has issues cos displaced and non displaced are different but also the same its a later problem
    legend([fixedNodeHandle, nodeHandle, frameHandle, trussHandle], {'Fixed Node', 'Node', 'Frame Element', 'Truss Element'});

    title('Structure Visualization');
    xlabel('X Coordinate');
    ylabel('Y Coordinate');
    axis equal;
    grid on;
end
