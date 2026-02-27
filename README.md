# Three-Node Torsional Spring (3NTS) Structural Analysis Toolkit

MATLAB code for nonlinear 2D bar-truss analysis with a three-node torsional spring (3NTS) element. The implementation combines axial bar elements and torsional spring elements without introducing rotational DOFs, then solves large-displacement response with either load control (Newton-Raphson) or arc-length control.

## Abstract

>This technical note presents the derivation, validation, and application of a *three-node torsional spring (3NTS)* element for the analysis of bar-linked, reconfigurable structures. The 3NTS element assigns rotational stiffness to a joint  (node) of two axial force members (bars) in truss-like assemblies. This element avoids the use of rotational degrees of freedom by recasting its resisting moment into equivalent nodal forces, which are consistent with global equilibrium, thereby keeping the model size compact and computationally efficient. The 3NTS is integrated into standard non-linear solvers to simulate large-displacement response and validated against analytical solutions of two benchmark examples: the simplest 3NTS structure and the buckling of a vertical column. We further apply the framework to a reconfigurable truss structure from our previous work to illustrate potential functional use cases and outline its broader applicability to metamaterials, kirigami systems, and biomechanical assemblies. An open-source matrix structural analysis tool implementing the 3NTS and axial force members is made available with this note.

## Citing this work

If you publish results that leverage this codebase, please cite the accompanying technical note on the 3NTS element. Include a pointer to this repository so other researchers can reproduce your simulations.
> Patil, H. Y., and Filipov, E. T. (2026). "Three-Node Torsional Spring Element Formulation for the Analysis of Reconfigurable Bar-Linked Structures." ASME. J. Appl. Mech. March 2026; 93(3): 034502. <https://doi.org/10.1115/1.4070821>
> 

## What is implemented

- 2D axial bar element routines: `barInfo`, `barStiffness`, `geomStiffness`, `barForceRec`, `transformationMatrix`
- 3NTS routines: `springInfo`, `springStiffness`
- Global assembly and bookkeeping: `numberDOF`, `generateMapping`, `loadVector`, `partitionStiffness`, `globalStiffness`
- Nonlinear solvers:
  - `solverLCM.m`: load-controlled Newton-Raphson
  - `solverALCM.m`: arc-length control method (fixed or automatic load stepping)
- Visualization and post-processing:
  - `plotStructure` (MP4 export)
  - `plotEnergy` (energy balance plot)
  - `plotForceDisp` (load-displacement curves)

## Repository structure

| Path | Purpose |
|---|---|
| `main.m` | Interactive entry point for selecting structure and solver |
| `validateTestStructure.m` | Validation workflow for the basic 3-node spring test problem |
| `validateVertCol.m` | Validation workflow for vertical-column buckling response |
| `core/` | Element-level mechanics, assembly, and indexing functions |
| `solver/` | Nonlinear solution algorithms |
| `structures/` | Predefined structure loaders returning `params` structs |
| `post/` | Plotting, drawing, and animation helpers |
| `videos/` | Saved structural deformation videos |
| `variableReference.md` | Variable glossary aligned with current code |

## Requirements

- MATLAB (tested against modern releases)
- Base MATLAB functions only (no special toolbox dependencies in source)

## Running an analysis

1. Open MATLAB and change directory to this repository.
2. Run:

```matlab
main
```

3. Choose a structure:
   - `0` Test structure
   - `1` Vertical column
   - `2` Cantilever truss
   - `3` Two-unit cantilever truss
   - `4` Shallow arch
   - `5` Warren truss

4. Choose a solver:
   - `0` Load-controlled solver (`solverLCM`)
   - `1` Arc-length solver (`solverALCM`)

5. If arc-length is selected, choose load stepping:
   - `0` Fixed
   - `1` Auto

After solving, `main.m` calls:
- `plotStructure(results, inputStructureName)`
- `plotEnergy(results)`
- `plotForceDisp(results)`

The deformation video is saved to:
- `videos/StructuralDeformation<StructureName>.mp4`

## Validation scripts

- `validateTestStructure.m`
  - Loads `loadTestStructure`
  - Runs `solverALCM`
  - Plots energy and force-displacement response (`plotForceDisp(results, [2])`)

- `validateVertCol.m`
  - Loads `loadVertColumn`
  - Runs `solverALCM`
  - Plots force-displacement response (`plotForceDisp(results, [1])`)
  - Overlays analytical buckling curve

## Structure loader contract

Each loader in `structures/` builds and returns a `params` struct containing:

- Topology and geometry: `links`, `springs`, `coords`
- Boundary and loading: `restraint`, `force`
- Material and spring properties: `A`, `E`, `kT`
- Initial element state: `L`, `L0`, `theta`, `theta0`, `alpha0`
- DOF indexing and maps: `identity`, `nFree`, `reshapeIdx`, `mapBars`, `mapSprings`
- Counts: `nNodes`, `nDof`, `nBars`, `nSpr`

The same field contract is used by both nonlinear solvers.

## Notes

- Documentation of all variables used in this codebase can be found in ['variableReference.md'](variableReference.md) 
- Plot export-to-SVG lines are included as commented code in plotting files.
