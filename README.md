# Three-Node Torsional Spring (3NTS) Structural Analysis Toolkit

This repository contains the MATLAB implementation referenced in the technical note below. The toolkit augments classical 2D axial bar formulations with the 3NTS element, letting you assign rotational stiffness to pin-jointed trusses without introducing rotational DOFs. The codebase assembles the mixed bar/spring system, runs linear and nonlinear solvers, and exports visualizations that highlight large-displacement behavior in reconfigurable bar-linked structures.

## Abstract

“This technical note presents the derivation, validation, and application of a *three-node torsional spring (3NTS)* element for the analysis of bar-linked, reconfigurable structures. The 3NTS element assigns rotational stiffness to a joint  (node) of two axial force members (bars) in truss-like assemblies. This element avoids the use of rotational degrees of freedom by recasting its resisting moment into equivalent nodal forces, which are consistent with global equilibrium, thereby keeping the model size compact and computationally efficient. The 3NTS is integrated into standard non-linear solvers to simulate large-displacement response and validated against analytical solutions of two benchmark examples: the simplest 3NTS structure and the buckling of a vertical column. We further apply the framework to a reconfigurable truss structure from our previous work to illustrate potential functional use cases and outline its broader applicability to metamaterials, kirigami systems, and biomechanical assemblies. An open-source matrix structural analysis tool implementing the 3NTS and axial force members is made available with this note.”

## Capabilities

- Assemble hybrid bar–spring models with arbitrary connectivity by combining loaders in `structures/` with the 3NTS element (`core/springStiffness.m`).
- Run multiple analyses from the same input data: eigenvalue checks, linear first-order, Euler incremental load steps, Newton–Raphson load control, and arc-length displacement control.
- Track internal axial forces, spring rotations, and total energy to validate equilibrium, stability boundaries, and conservation of work.
- Generate publication-ready plots (force–displacement, energy balance) and `.mp4` animations of structural deformation for each scenario.
- Reproduce benchmark problems from the paper via the `validate*.m` scripts.

## Repository layout

| Path | Description |
|---|---|
| `core/` | Element routines (axial stiffness, geometric stiffness, spring stiffness, DOF bookkeeping, global assembly). |
| `solver/` | Analysis algorithms (`eigenValueAnalysis`, `elasticFirstOrder`, `eulerSolver`, `loadControlSolver`, `dispControlSolver`). |
| `structures/` | Predefined problem definitions (`loadTestStructure`, `loadVertColumn`, `loadCantileverTruss`, etc.). Each returns a populated `params` struct. |
| `post/` | Plotting helpers and drawing utilities used for videos/figures. |
| `figures/`, `videos/` | Output folders created by the plotting routines. |
| `validateTestStructure.m`, `validateVertCol.m` | Scripts that compare solver output against analytical benchmarks from the note. |
| `variableReference.md` | Living glossary of every symbol used across the codebase. |

## Requirements

- MATLAB R2022b or newer (tested with R2024a). Earlier versions should work if they include `VideoWriter` and modern graphics.
- No external toolboxes are required; only base MATLAB functions are used.

## Quick start

1. Open MATLAB and `cd` into this repository.
2. Execute `main`. The script adds all subfolders to the path, prompts for a structure (0–5), then prompts for an analysis type (0–4).
3. After the solver finishes, review the console logs and generated plots/animations:
   - Deformation video saved to `videos/StructuralDeformation<Structure>.mp4`.
   - Energy balance and force–displacement figures shown in MATLAB (export steps are included in the plotting files if SVGs are desired).

### Available solvers (menu in `main.m`)

| Choice | Function | Purpose |
|---|---|---|
| `0` | `eigenValueAnalysis` | Linear eigenvalue extraction on the free DOF stiffness matrix for quick stability checks. |
| `1` | `elasticFirstOrder` | Single-step linear elastic solution. |
| `2` | `eulerSolver` | Incremental load-updating with Euler’s method. |
| `3` | `loadControlSolver` | Newton–Raphson load control with tangent stiffness updates and residual monitoring. |
| `4` | `dispControlSolver` | Arc-length (displacement-controlled) solver with optional automatic load-step sizing. |

### Predefined structures (menu in `main.m`)

0. Test structure (single 3NTS + two bars)
1. Vertical column (buckling benchmark)
2. Cantilever truss
3. Two-unit cantilever truss
4. Shallow arch truss
5. Warren truss

You can add more loaders following the pattern in `structures/load*.m`: supply `links`, `springs`, `coords`, boundary conditions, and material data, then call `barInfo`, `springInfo`, `numberDOF`, and `generateMapping` before returning the struct.

## Validation & reproducibility

- `validateTestStructure.m` – runs the arc-length solver on the canonical 3NTS configuration and compares the numerical response with the analytical solution from the note.
- `validateVertCol.m` – reproduces the vertical column buckling benchmark, overlaying analytical and numerical force–displacement curves.

Both scripts add the necessary paths automatically; run them directly from MATLAB to regenerate the figures shown in the paper.

## Post-processing outputs

- `plotStructure` – builds smooth animations of bar deformation, spring contraction/expansion, and applied force vectors. Videos render off-screen for repeatable exports.
- `plotEnergy` – compares external work with the sum of bar and spring strain energies; reports max relative error to confirm energy balance.
- `plotForceDisp` – draws load–displacement histories for any set of free DOFs; the validation scripts use this to overlay analytical curves.

## Customization tips

- Update or duplicate the loaders in `structures/` to explore new geometries. Since the solvers operate on the `params` struct, keeping field names consistent is all that is required.
- The full list of parameters (including solver histories such as `delta`, `P`, `alpha`, `axialF`, and residuals) is documented in [`variableReference.md`](variableReference.md). Use it as a reference when adding new solvers, plotting routines, or exporting data.
- Post-processing functions operate on the `results` struct returned by any solver, so custom scripts can create additional plots by accessing the same fields.

## Citing this work

If you publish results that leverage this codebase, please cite the accompanying technical note on the 3NTS element. Include a pointer to this repository so other researchers can reproduce your simulations.
> Patil, H. Y. and Filipov, E. T. (In press) Three-node torsional spring element formulation for the analysis of reconfigurable bar-linked structures. ASME Journal of Applied Mechanics