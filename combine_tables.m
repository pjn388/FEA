% table combiner uses names to combine tables
% this function allows the combinaation of named tables mostly to avoid mistakes in global matrix construction
function combinedTable = combine_tables(varargin)
    tables = varargin;
    dosum = true;

    if length(varargin) == 1
        combinedTable = varargin{1};
        return;
    end

    if ~isa(varargin{1, end-1}, 'table') % matlab throws an error instead of returning false when u do a comparision between different types it also does implied convsersion so its the worst of both worlds
        if varargin{1, end-1} == "dosum"
            dosum = varargin{1,end}; 
            tables = varargin(1:end-2);
        end
    end

    allRowNames = [];
    allVarNames = [];

    % Loop through each table to collect row and variable names
    for i = 1:length(tables)
        if isempty(tables{i})
            continue;
        end
        allRowNames = [allRowNames; tables{i}.Properties.RowNames];
        allVarNames = [allVarNames, tables{i}.Properties.VariableNames];
    end

    allRowNames = unique(allRowNames);
    allVarNames = unique(allVarNames);

    % Create an empty table with all unique row and variable names
    combinedTable = array2table(zeros(length(allRowNames), length(allVarNames)), ...
        'RowNames', allRowNames, 'VariableNames', allVarNames);

    combinedTable = tableToSym(combinedTable);

    for k = 1:length(tables)
        currentTable = tables{k};
        % Loop through each element in the current table, accumulating values into combinedTable
        for i = 1:height(currentTable)
            rowName = currentTable.Properties.RowNames{i};
            for j = 1:width(currentTable)
                varName = currentTable.Properties.VariableNames{j};
                if dosum
                    combinedTable{rowName, varName} = combinedTable{rowName, varName} + currentTable{rowName, varName};
                else
                    combinedTable{rowName, varName} = currentTable{rowName, varName};
                end
            end
        end
    end
end
