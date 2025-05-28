# Thermal & Structural Analysis Script

This script performs thermal and structural analysis on a given set of nodes, elements, and constraints. It calculates solutions and renders both the initial and displaced/temperature distributions.

## Dependencies

-   MATLAB

## Usage

1.  **Define Nodes:** Specify node locations using classes like `FixedNode2D` and `Node2D`.
2.  **Define Elements:** Define structural elements (`FrameElement`, `TrussElement`) or thermal elements (`ThermalTriangleElement`, `ThermalRectangleElement`, `Thermal1D`) connecting the nodes, along with their properties.
3.  **Define Constraints:**  Specify constraints between nodes using the `Constraint` class for Multi-Point Constraints (MPC) to connect complex sub-structures.
4.  **Apply Loads/Boundaries:** Apply loads to nodes (structural) or boundary conditions to elements (thermal) using methods like `apply_loading`, `apply_boundary`.
5.  **Run the Analysis:** Execute the `fea_solve` function.

## File Descriptions

-   `thermal.m`: Defines the thermal model including nodes, elements, and boundary conditions. This is a primary setup file example.
-   `combined.m`: Example structural setup
-   `fea_solve.m`: Performs the analysis calculations, applies constraints, solves for solutions, and renders the results.
-   `init.m`: Used to initialize the file by adding all foldes
-   `units.m`: Used to set units

## Classes

-   `FixedNode2D`: Represents a fixed node in 2D space.
-   `Node2D`: Represents a node in 2D space with free solutions.
-   `FrameElement`: Represents a frame element with axial, shear, and bending stiffness.
-   `TrussElement`: Represents a truss element with axial stiffness only.
-   `Constraint`: Defines a constraint between two nodes, linking their degrees of freedom (DOFs).
-   `ThermalTriangleElement`: Represents a thermal triangle element.
-   `ThermalRectangleElement`: Represents a thermal rectangle element.
-   `Thermal1D`: Represents a 1D thermal element (e.g., for convection).
-   `ThermalMaterial`: Defines thermal material properties (thermal conductivity).
-   `FixedTemperatureBoundary`: Defines a fixed temperature boundary condition.
-   `HeatFluxBoundary`: Defines a heat flux boundary condition.
-   `ConvectionBoundary`: Defines a convection boundary condition.

## Workflow

1.  A setup script (`thermal.m` or `combined.m`) defines the model.
2.  `fea_solve.m` computes element stiffness (structural) or conductance (thermal) matrices, combines them into a global matrix (`global_K_table`), and creates a global force/heat flow vector (`global_F_table`).
3.  Constraints are applied to the global matrix by merging constrained DOFs.
4.  Fixed boundary conditions are applied by eliminating rows and columns from the global matrix and force/heat flow vector.
5.  The system of equations is solved to determine solutions (displacements or temperatures).
6.  Solutions from constrainted dof's are back substituted.
7.  The deformed structure or temperature distribution is rendered, with solutions exaggerated for visibility (structural) or displayed as a heatmap (thermal).
## Notes

-   The script can be extended to 3D or more complex elements with modifications.
-   Units must be defined correctly.
-   The `exageration_factor` (structural) controls the solution scaling for rendering.
## Donations

* monero:83B495T1N3sje9vXMqNShbSx99g1QjKyL8YKjvU6rt6hAkmwbVUrQ65QGEUsL3QxVPdtiK91GnCP7bG2oCz7h1PDKsoCPB1
* ![monero:83B495T1N3sje9vXMqNShbSx99g1QjKyL8YKjvU6rt6hAkmwbVUrQ65QGEUsL3QxVPdtiK91GnCP7bG2oCz7h1PDKsoCPB1](https://raw.githubusercontent.com/pjn388/FEA/refs/heads/main/images/uni_recieve.png?raw=true)
