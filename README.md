# Structural Analysis Script

This script performs structural analysis on a given set of nodes, elements, and constraints. It calculates displacements and renders both the initial and displaced structures.

## Dependencies

-   MATLAB

## Usage

1.  **Define Nodes:** Specify the location and properties of nodes using classes like `FixedNode2D` and `Node2D`.
2.  **Define Elements:** Define structural elements (e.g., `FrameElement`, `TrussElement`) connecting the nodes, along with their properties (A, E, I).
3.  **Define Constraints:**  Specify constraints between nodes using the `Constraint` class, particularly for Multi-Point Constraints (MPC) to connect complex sub-structures.
4.  **Apply Loads:** Apply loads to the nodes using the `apply_loading` method.
5.  **Run the Analysis:** Execute the `main.m` script.

## File Descriptions

-   `combined.m`:  Defines the structural model including nodes, elements, constraints, and loads.  This is the primary setup file.
-   `main.m`:  Performs the structural analysis calculations, applies constraints, solves for displacements, and renders the results.

## Classes

-   `FixedNode2D`: Represents a fixed node in 2D space.
-   `Node2D`: Represents a node in 2D space with free displacement.
-   `FrameElement`: Represents a frame element with axial, shear, and bending stiffness.
-   `TrussElement`: Represents a truss element with axial stiffness only.
-   `Constraint`:  Defines a constraint between two nodes, linking their degrees of freedom (DOFs).

## Workflow

1.  The `combined.m` script sets up the structural model.
2.  `main.m` computes element stiffness tables, combines them into a global stiffness matrix (`global_K_table`), and creates a global force vector (`global_F_table`).
3.  Constraints are applied to the global stiffness matrix by merging constrained DOFs.
4.  Fixed boundary conditions are applied by eliminating rows and columns from the global stiffness matrix and force vector.
5.  The system of equations is solved to determine displacements.
6.  Displacements from constrainted dof's are back substituted.
7.  The deformed structure is rendered, with displacements exaggerated for visibility.

## Notes

-   The script is designed to be extendable to 3D or more than 2 nodes per element, but this would require significant modifications.
-   The `in` and `lb` variables in `combined.m` convert to SI units.
-   The `exageration_factor` in `main.m` controls the displacement scaling for rendering.
-   Comments in the code provide additional details on the implementation.


## Donations

* monero:83B495T1N3sje9vXMqNShbSx99g1QjKyL8YKjvU6rt6hAkmwbVUrQ65QGEUsL3QxVPdtiK91GnCP7bG2oCz7h1PDKsoCPB1
* ![monero:83B495T1N3sje9vXMqNShbSx99g1QjKyL8YKjvU6rt6hAkmwbVUrQ65QGEUsL3QxVPdtiK91GnCP7bG2oCz7h1PDKsoCPB1](https://raw.githubusercontent.com/pjn388/FEA/refs/heads/main/static/images/uni_recieve.png?raw=true)
