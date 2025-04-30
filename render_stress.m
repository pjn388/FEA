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
