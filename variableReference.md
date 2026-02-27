# Simulation Variable Reference

This document reflects the current MATLAB source in this repository and focuses on variables used by loaders, solvers, core assembly functions, and post-processing.

## Entry-point and script variables

| Variable | Type / Size | Where | Description |
|---|---|---|---|
| `structType` | scalar | `main.m` | User choice for predefined structure (`0` to `5`). |
| `inputStructure` | struct | `main.m`, `validate*.m` | Structure definition returned by a `load*.m` function. |
| `inputStructureName` | string | `main.m`, `validate*.m` | Name tag used for plot/video titles and file naming. |
| `simType` | scalar | `main.m` | Solver choice (`0`: load control, `1`: arc length). |
| `results` / `outParams` | struct | solvers + `post/` | Solver output struct consumed by plotting functions. |

## Loader output (`params`) fields

All active loaders (`loadTestStructure`, `loadVertColumn`, `loadCantileverTruss`, `load2UnitCantileverTruss`, `loadShallowArch`, `loadWarrenTruss`, `loadColBars`) use this contract.

| Field | Type / Size | Description |
|---|---|---|
| `links` | `nBars x 2` | Bar connectivity `[node_i, node_j]`. |
| `springs` | `nSpr x 3` | 3NTS connectivity `[node_1, node_2, node_3]` (`node_2` is the spring center). |
| `coords` | `nNodes x 2` | Nodal coordinates `[x, y]`. |
| `restraint` | `nNodes x nDof` | DOF restraints (`1` fixed, `0` free). |
| `force` | `nNodes x nDof` | Applied nodal loads in global axes. |
| `A` | `nBars x 1` | Bar cross-sectional area. |
| `E` | `nBars x 1` | Bar Young's modulus. |
| `L` | `nBars x 1` | Current bar lengths (initialized from undeformed geometry). |
| `L0` | `nBars x 1` | Initial bar lengths. |
| `theta` | `nBars x 1` | Current bar angles (initialized from undeformed geometry). |
| `theta0` | `nBars x 1` | Initial bar angles. |
| `kT` | `nSpr x 1` | Torsional spring stiffness values. |
| `alpha0` | `nSpr x 1` | Initial spring relative angles from `springInfo`. |
| `identity` | `nNodes x nDof` | Global DOF numbering with free DOFs first. |
| `nNodes`, `nDof`, `nBars`, `nSpr` | scalar | Model sizes/counts. |
| `nFree` | scalar | Number of free DOFs. |
| `reshapeIdx` | `(nNodes*nDof) x 1` | Permutation index between nodal and solver-ordered vectors. |
| `mapBars` | `nBars x (2*nDof)` | DOF map for each bar. |
| `mapSprings` | `nSpr x (3*nDof)` | DOF map for each spring. |

## Core function variables

| Variable | Type / Size | Function(s) | Description |
|---|---|---|---|
| `D` | `nBars x 2` | `barInfo` | Bar direction vectors (`coords(j)-coords(i)`). |
| `T` | `4 x 4` | `transformationMatrix`, `barForceRec`, `globalStiffness` | Global-local transform for bar DOFs. |
| `kLocal` | `4 x 4` | `barStiffness`, `barForceRec`, `globalStiffness` | Local axial stiffness matrix for a bar. |
| `kGeom` | `4 x 4` | `geomStiffness`, `barForceRec`, `globalStiffness` | Geometric stiffness from axial force. |
| `pSystem` | `(nNodes*nDof) x 1` | `loadVector` | System load vector ordered by `reshapeIdx`. |
| `Kff`, `Ksf` | matrices | `partitionStiffness`, solvers | Free-free and support-free stiffness partitions. |
| `intFBar`, `intFSpr` | vectors | `globalStiffness` | Internal force accumulators for bars and springs. |
| `intF` | `(nNodes*nDof) x 2` | `globalStiffness` | Internal force output (`[:,1]` bars, `[:,2]` springs). |
| `axialF` | `nBars x (maxIncr+1)` | `globalStiffness`, solvers | Running axial-force history used for geometric stiffness. |

### Spring formulation variables (`springInfo`, `springStiffness`)

| Variable | Type / Size | Description |
|---|---|---|
| `r1`, `r2`, `r3` | `2 x 1` vectors | Position vectors of the three spring nodes. |
| `a`, `b` | `2 x 1` vectors | Segment vectors from center node to outer spring nodes. |
| `N` | `2 x 2` | Skew matrix `[0 -1; 1 0]` for 90-degree rotation operations. |
| `C`, `S` | scalar | Dot/cross-like terms used to compute relative angle `alpha`. |
| `alpha` | scalar or `nSpr x 1` | Current relative spring angle(s). |
| `J` | `6 x 2` | Jacobian of spring angle wrt nodal coordinates. |
| `H` | `6 x 6` | Hessian used for consistent tangent stiffness. |
| `M` | scalar | Spring moment, `kT * (alpha - alpha0)`. |
| `kSpring` | `6 x 6` | Spring tangent stiffness matrix. |

## Nonlinear solver variables (`solverLCM`, `solverALCM`)

| Variable | Type / Size | Description |
|---|---|---|
| `maxIncr` | scalar | Number of load increments (`100` in `solverLCM`; fixed/auto in `solverALCM`). |
| `maxIter`, `minIter` | scalar | Newton/arc-length iteration limits per increment. |
| `errTol`, `err` | scalar | Convergence tolerance and current error value. |
| `lambda` | `maxIter x maxIncr` | Load scaling factors. |
| `PRef` | `(nNodes*nDof) x 1` | Reference load vector from `force`. |
| `R` | `nFree x 1` | Residual vector (`external - internal`) over free DOFs. |
| `dUP` | `nFree x maxIter x maxIncr` | Displacement direction from reference load. |
| `dUR` | `nFree x maxIter x maxIncr` | Displacement correction direction from residual. |
| `dU` | `(nNodes*nDof) x maxIter x maxIncr` | Incremental displacement contributions. |
| `dP` | `(nNodes*nDof) x maxIter x maxIncr` | Incremental nodal load/reaction contributions. |
| `U`, `P` | `(nNodes*nDof) x (maxIncr+1)` | Total displacement and load histories. |
| `barIntForce`, `sprIntForce`, `intForce` | `(nNodes*nDof) x (maxIncr+1)` | Internal-force histories for bars, springs, and total. |
| `alpha` | `nSpr x (maxIncr+1)` | Spring-angle history (initialized with `alpha0`). |
| `nodeLoc` | `nNodes x nDof x (maxIncr+1)` | Nodal coordinates at each converged increment. |
| `nodeForce` | `nNodes x nDof x (maxIncr+1)` | Nodal forces at each converged increment. |
| `coordsPrev` | `nNodes x 2` | Last coordinate state used for incremental bar-force recovery. |

### Arc-length specific variables (`solverALCM`)

| Variable | Type / Size | Description |
|---|---|---|
| `autoLoadStep` | scalar | User choice (`0` fixed, `1` auto stepping). |
| `loadFactor` | scalar | Fixed arc-length step size when `autoLoadStep == 0`. |
| `gamma` | scalar | Exponent for adaptive load-step update. |
| `CSP` | `maxIncr x 1` | Current stiffness parameter for automatic stepping. |
| `dirSign` | scalar (`+1`/`-1`) | Direction tracking for signed step progression. |
| `dUi_1` | `nFree x 1` | Previous increment displacement used for direction check. |

## Solver output struct fields (`outParams`)

Both solvers return these fields:

- Input/model fields carried forward:
  - `links`, `springs`, `coords`, `restraint`, `force`, `A`, `E`, `L`, `L0`, `theta`, `theta0`, `kT`, `alpha0`, `identity`, `nNodes`, `nDof`, `nBars`, `nSpr`, `nFree`, `reshapeIdx`, `mapBars`, `mapSprings`
- History/result fields:
  - `alpha`, `numSteps`, `P`, `U`, `nodeForce`, `nodeLoc`, `sprIntForce`, `barIntForce`, `intForce`

## Post-processing variables

| Variable | Type / Size | Function | Description |
|---|---|---|---|
| `barThickness` | scalar | `plotStructure`, `draw*` | Visual scale, set from mean undeformed bar length. |
| `triSize` | scalar | `plotStructure` | Support glyph size. |
| `videoFile`, `v` | string, `VideoWriter` | `plotStructure` | MP4 output path and writer object. |
| `externalWork` | `1 x (numSteps+1)` | `plotEnergy` | Cumulative external work by trapezoidal integration. |
| `springEnergy` | `1 x (numSteps+1)` | `plotEnergy` | Spring strain energy history. |
| `barEnergy` | `1 x (numSteps+1)` | `plotEnergy` | Integrated bar internal work history. |
| `internalWork` | `1 x (numSteps+1)` | `plotEnergy` | `barEnergy + springEnergy`. |
| `energyDiff` | `1 x (numSteps+1)` | `plotEnergy` | Absolute energy imbalance magnitude. |
| `dofList` | vector | `plotForceDisp` | Selected free DOF indices to plot; defaults to all free DOFs. |
