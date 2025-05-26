% arr1 = [Node2D(1, 2), Node2D(3, 4), Node2D(5, 6)];
% arr2 = [Node2D(3, 4), Node2D(1, 2), Node2D(5, 6)];
% arr3 = [Node2D(5, 6), Node2D(1, 2), Node2D(3, 4)]; % Same elements, different order
% arr4 = [Node2D(1, 2), Node2D(3, 4), Node2D(7, 8)]; % Different elements
% arr5 = [Node2D(1, 2), Node2D(3, 4)]; % Different length

% % Test the function
% isEqual1 = is_members_match(arr1, arr2) % Should be true
% isEqual2 = is_members_match(arr1, arr3) % Should be true
% isEqual3 = is_members_match(arr1, arr4) % Should be false
% isEqual4 = is_members_match(arr1, arr5) % Should be false


function isEqual = is_members_match(arr1, arr2)
    % Check if the arrays have the same number of elements.
    if length(arr1) ~= length(arr2)
        isEqual = false;
        return;
    end
    
    % Convert arrays to struct arrays for comparison
    structArr1 = arrayfun(@(obj) struct('x', obj.x, 'y', obj.y), arr1);
    structArr2 = arrayfun(@(obj) struct('x', obj.x, 'y', obj.y), arr2);

    % Sort the struct arrays based on x, then y
    structArr1 = sortStructArray(structArr1);
    structArr2 = sortStructArray(structArr2);
    
    % Compare sorted struct arrays
    isEqual = isequal(structArr1, structArr2);
end

function sortedStructArray = sortStructArray(structArray)
    % Convert struct array to a table
    T = struct2table(structArray);
    
    % Sort the table by 'x' and then by 'y'
    TSorted = sortrows(T, {'x', 'y'});
    
    % Convert the sorted table back to a struct array
    sortedStructArray = table2struct(TSorted);
end