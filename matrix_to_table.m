% generic matrix to table conversion. Takes a dof alligned matrix for an element and makes a labeled table based on its dofs 
% This use usefull as it labels rows and columns to allow for commbination based on these row/column values 
function T = matrix_to_table(matrix_data, nodes, dof, varargin)

    % Input parser (matlab makes the simple tasks hard)
    p = inputParser;
    addParameter(p, 'isload', false, @islogical);
    parse(p, varargin{:});
    isload = p.Results.isload;

    % make dof labels
    dof_labels = strings(1, length(nodes) * length(dof));
    for i = 1:length(nodes)

        for j = 1:length(dof)
            dof_labels((i-1)*length((dof))+j) = "Node_" + nodes{i}.uuid + "_" + dof(j);
        end

    end
    
    
    % sometime the impossible is possible and debuging the impossible when its not clear is impossible
    if size(matrix_data,1) ~= length(dof_labels)
        warning('Stiffness matrix size does not match expected number of DOFs. This error should NEVER happen something has gone seriously wrong.');
        T = table();
        return;
    end
    
    % actually do conversion
    if isload
        num_cols = size(matrix_data, 2);
        col_labels = strings(1, num_cols);
        for i = 1:num_cols
            col_labels(i) = "Load_" + i;
        end
        T = array2table(matrix_data, ...
            'VariableNames', col_labels, ...
            'RowNames', dof_labels);
    else
        T = array2table(matrix_data, ...
            'VariableNames', dof_labels, ...
            'RowNames', dof_labels);
    end
end
