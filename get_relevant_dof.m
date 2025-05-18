% gets the relevent dof's values from an array of dof's and their values
function relevant_values = get_relevant_dof(dofs, values, relevant_dofs)
    relevant_values = zeros(length(relevant_dofs), 1);
    for i = 1:length(relevant_dofs)
        dof_index = find(strcmp(dofs, relevant_dofs{i}));
        if ~isempty(dof_index)
            relevant_values(i) = values(dof_index);
        end
    end
end