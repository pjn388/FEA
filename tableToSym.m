% data = table([1; 2; 3], {'a'; 'b'; 'c'}, [4.5; 5.5; 6.5], 'VariableNames', {'Num', 'Char', 'Double'});

% % Display the original table
% disp('Original Table:');
% disp(data);

% % Convert double columns to symbolic
% newData = tableToSym(data);

% % Display the new table with symbolic values
% disp('Table with Symbolic Values:');
% disp(newData);

% newData{1, 1}
% class(newData{1, 1})



function newData = tableToSym(data)
    %TABLETOSYM Converts a table to a table with symbolic values.
    %   newData = TABLETOSYM(data) converts all eligible columns (e.g., double)
    %   in the table 'data' to symbolic type.

    newData = data;
    for i = 1:width(data)
        if isa(data.(i), 'double')
            newData.(i) = sym(data.(i));
        end
    end
end