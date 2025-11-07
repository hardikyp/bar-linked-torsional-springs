# Simulation Variables Reference

This repository revolves around MATLAB implementations of axial bar elements coupled with three-node torsional springs (3NTS). The same set of arrays, scalars, and structs flows through the structure loaders (`structures/`), solvers (`solver/`), stiffness assembly (`core/`), and plotting/validation scripts (`post/`, `validate*.m`). Tables below summarize the variables by responsibility; sizes assume the default 2D truss case where each node has two DOFs (`nDof = 2`).

## Execution-time selectors & I/O structs
| Variable | Type / Size | Where used | Description |
|---|---|---|---|
| `structType` | scalar double | `main.m` | Menu choice (0–5) indicating which predefined structure loader to call. |
| `inputStructure` | struct | `main.m`, solvers | Encapsulates geometry, material data, connectivity, and precomputed indexing. Each `load*.m` function populates the fields listed in later tables. |
| `inputStructureName` | string | `main.m`, `plotStructure` | Short tag for naming videos and figures (e.g., `"VertCol"`). |
| `simType` | scalar double | `main.m` | Menu choice (0–4) selecting the solver (eigenvalue, first-order, Euler, load control, displacement control). |
| `results` / `outParams` | struct | solvers, `post/` | Solver output that contains the original `params` plus histories (`delta`, `P`, `nodeLoc`, energies, etc.). |

## Geometry, connectivity & material properties (loader outputs)
| Variable | Type / Size | Meaning |
|---|---|---|
| `links` | `nBars × 2` double | Node IDs for each axial bar (`[node_i, node_j]`). |
| `springs` | `nSpr × 3` double | Three-node torsional spring connectivity (`[n1, n2, n3]`, with `n2` being the joint). |
| `coords` | `nNodes × 2` double | Initial nodal coordinates `[x, y]`. |
| `restraint` | `nNodes × nDof` logical/double | Boundary conditions (`1` fixed, `0` free) per DOF. |
| `force` | `nNodes × nDof` double | Prescribed nodal load components in global axes. |
| `A`, `E` | `nBars × 1` double | Cross-sectional areas and Young’s moduli for each bar. |
| `kT` | `nSpr × 1` double | Rotational stiffness of each 3NTS element. |
| `L`, `theta` | `nBars × 1` double | Current bar lengths and orientations returned by `barInfo`. Initialized to undeformed state. |
| `L0`, `theta0` | `nBars × 1` double | Reference (original) lengths and angles. |
| `alpha0` | `nSpr × 1` double | Rest angles between bar pairs for each spring (`springInfo`). |
| `alpha` | `nSpr × (maxIncr+1)` double | Spring rotation history updated in `dispControlSolver` for energy checks. |
| `nNodes`, `nBars`, `nSpr`, `nDof` | scalar double | Problem sizes; default `nDof = 2`. |

## Indexing & assembly helpers
| Variable | Type / Size | Meaning |
|---|---|---|
| `totalDof` | scalar (`nNodes * nDof`) | Total number of structural DOFs. Not stored explicitly but implied throughout. |
| `identity` | `nNodes × nDof` double | Maps each nodal DOF to its position in the permuted global ordering (free DOFs first). Produced by `numberDOF`. |
| `nFree` | scalar | Number of free DOFs (count of zeros in `restraint`). |
| `reshapeIdx` | `totalDof × 1` double | Flattened permutation vector used to reshape between `[node, dof]` ordering and solver ordering. |
| `mapBars` | `nBars × (2*nDof)` | DOF indices for each bar (two nodes). Used when assembling bar contributions. |
| `mapSprings` | `nSpr × (3*nDof)` | DOF indices for each spring (three nodes). |

## Global matrices, forces & displacements
| Variable | Type / Size | Meaning |
|---|---|---|
| `kSystem` | `totalDof × totalDof` double | Assembled tangent stiffness from bars (`barStiffness` + `geomStiffness`) and springs (`springStiffness`). |
| `Kff`, `Ksf` | matrices | Free–free and restrained–free partitions of `kSystem` returned by `partitionStiffness`. |
| `kLocal` | `4 × 4` double | Local axial bar stiffness from `barStiffness`. |
| `kGeom` | `4 × 4` double | Geometric stiffness derived from current axial force (`geomStiffness`). |
| `kSpring` | `6 × 6` double | Local torsional spring stiffness assembled inside `springStiffness`. |
| `T` | `4 × 4` double | Direction cosine matrix from `transformationMatrix`. |
| `Pref` | `totalDof × 1` double | Full load vector assembled from `force` via `loadVector`. Scaled to form incremental loads. |
| `P`, `dP` | `totalDof × (maxIncr+1)` and `totalDof × maxIncr` | Total and incremental load histories. In nonlinear solvers `dP` also stores reactions for restrained DOFs. |
| `delta`, `dDelta` | `totalDof × (maxIncr+1)` and `totalDof × maxIter × maxIncr` | Total and incremental displacement histories. |
| `nodeLoc` | `nNodes × nDof × (maxIncr+1)` | Nodal coordinates after each increment (`coords` + reshaped `delta`). |
| `nodeForce` | `nNodes × nDof × (maxIncr+1)` | Reaction + applied forces converted back to nodal ordering for plotting. |
| `barIntForce`, `sprIntForce` | `totalDof × (maxIncr+1)` | Accumulated internal nodal forces caused by bars and springs, tracked for residual calculations and energy plots. |
| `intF` | `totalDof × 2` double | Column 1 = new bar contribution, column 2 = spring contribution, from `globalStiffnessNL`. |
| `axialF` | `nBars × (maxIncr+1)` | Axial force history per bar; feeds `geomStiffness` and energy routines. |
| `numSteps` | scalar | Number of increments actually executed; used by plotting utilities to loop over histories. |

## Nonlinear solver bookkeeping
| Variable | Type / Size | Meaning |
|---|---|---|
| `maxIncr` | scalar | Target number of load/displacement increments (100 for Euler and load-control, 700 or `1/loadFactor` for arc-length, 1 for linear analyses). |
| `maxIter`, `minIter` | scalars | Iteration caps/minimums inside Newton or arc-length loops. |
| `autoLoadStep`, `loadFactor` | scalars | User input for arc-length solver; selects adaptive vs fixed load-step scheme. |
| `lambda` | `maxIter × maxIncr` double | Load-scaling factors used in nonlinear solvers (per iteration for arc-length, per increment for load-control). |
| `R` | `nFree × 1` double | Residual force vector (`external - internal`) for Newton iterations. |
| `err`, `errTol` | scalars | Current residual/displacement norm and associated stopping tolerance. |
| `coordsPrev` | `nNodes × 2` | Last converged coordinates; needed for incremental strain evaluation in `barForceRec`. |
| `dDeltaSD`, `dDeltaDD`, `dDeltaSD11` | vectors | Secant, dynamic, and reference displacement directions used by the arc-length algorithm to compute `lambda`. |
| `S` | `maxIncr × 1` double | Scaling history that relates first-step and subsequent secant directions for automatic load stepping. |
| `dirSign` | scalar (+1/-1) | Tracks whether the method is following or reversing the previous displacement path when sign changes occur. |

## Element-level helper quantities
| Variable | Type / Size | Meaning |
|---|---|---|
| `D` | `nBars × 2` double | Vector differences `coords(j,:) - coords(i,:)` used by `barInfo`. |
| `dU`, `dULocal` | vectors | Incremental displacements in global and local bar frames. |
| `natDef` | scalar | Natural (axial) deformation of a bar (`[-1 0 1 0] * dULocal`). |
| `r1`, `r2`, `r3` | `2 × 1` vectors | Node position vectors for a spring. |
| `a`, `b` | `2 × 1` vectors | Bar direction vectors entering/leaving the middle node of a spring. |
| `N` | `2 × 2` constant | Skew-symmetric matrix `[0 -1; 1 0]` used to rotate vectors by +90°. |
| `J` | `6 × 2` stacked blocks | Jacobian relating nodal displacements to spring rotation change. |
| `H` | `6 × 6` | Hessian of the spring rotation w.r.t. nodal coordinates (needed for consistent stiffness). |
| `M` | scalar | Spring moment (`kT * (alpha - alpha0)`). |

## Energy & plotting helpers
| Variable | Type / Size | Meaning |
|---|---|---|
| `externalWork` | row vector | Cumulative work from global loads: trapezoidal integration of `P` vs `delta`. |
| `springEnergy` | row vector | `0.5 * kT .* (alpha - alpha0).^2` per increment. |
| `barEnergy` | row vector | Work done by bar internal forces (`barIntForce`) over incremental displacements. |
| `energyDiff` | row vector | Absolute difference between `externalWork` and total internal energy, plotted to check conservation. |
| `barThickness`, `triSize` | scalars | Derived plot dimensions based on mean bar length, used by the drawing utilities. |
| `videoFile`, `v` | string / `VideoWriter` | Output path and writer handle used by `plotStructure` to export `.mp4` animations. |

### Notes
- MATLAB stores indices as doubles; whenever you see integer-like arrays (`links`, `mapBars`, etc.) they are still `double` but only used as indices.
- All solvers keep free DOFs first in every vector/matrix; use `reshapeIdx` whenever converting to/from nodal layouts to avoid mixing restrained DOFs.
- `numSteps` equals `maxIncr` for fixed-step solvers; in adaptive arc-length runs, it reflects however many increments actually converged before the loop ended.
