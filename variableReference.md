# Simulation Variables Reference

This document lists variables used across the reconfigurable truss simulation code (from `AllCode.txt`). For array sizes we use symbolic names:

- `nNodes` — number of nodes in the structure
- `nBars`  — number of bar elements (links)
- `nSpr`   — number of rotational (three-node) springs
- `nDof`   — degrees of freedom per node (2 in this code: x and y)
- `totalDof` — total degrees of freedom = `nNodes * nDof`
- `maxIncr` / `maxIter` — algorithm dependent time/iteration dimensions

> Note: MATLAB uses `double` by default for numeric arrays. Where code treats values as integers (indices), those are still MATLAB `double` but represent integer indices. Descriptions indicate the intended use and typical sizes for the default 2D truss setup (`nDof = 2`).

---

| Variable | Type | Size (MATLAB) | Description |
|---|---:|---:|---|
| `structType` | scalar (double/int) | `1×1` | User choice of which structure to load (0..3). |
| `inputStructure` | struct | scalar | Struct returned by a loader (`loadTestStructure`, `loadCantileverTruss`, etc.). Contains most simulation inputs. |
| `inputStructureName` | string | `1×1` | Human-readable name for the selected structure. |
| `simType` | scalar (double/int) | `1×1` | User choice of simulation routine (0..4). |
| `postProcessData` | struct | scalar | Results returned by solver functions, used for plotting. |

---

## Core geometry & connectivity

| Variable | Type | Size (MATLAB) | Description |
|---|---:|---:|---|
| `links` | array (double) | `nBars × 2` | Bar connectivity: each row `[node_i, node_j]`. Node indices (1-based). |
| `springs` | array (double) | `nSpr × 3` | Rotational spring connectivity: each row `[n1, n2, n3]` (three-node spring where `n2` is the center node). |
| `coords` | array (double) | `nNodes × 2` | Nodal coordinates: columns `[x, y]`. |
| `restraint` | array (double: 0/1) | `nNodes × nDof` | Boundary conditions per node: `1` = restrained, `0` = free. Rows correspond to nodes, columns to DOF (x,y). |
| `force` | array (double) | `nNodes × nDof` | External nodal forces: rows for nodes, columns `[Fx, Fy]`. |
| `identity` | array (double/int) | `nNodes × nDof` | DOF identity mapping produced by `numberDOF`. Values map each node DOF to a global ordering index. |
| `reshapeIdx` | vector (double/int) | `totalDof × 1` | Index order used to reshape/permute vectors between nodal and global representations. |
| `mapBars` | array (double/int) | `nBars × (nDof*2)` (e.g., `nBars × 4`) | For each bar, global DOF indices for its two nodes (used when assembling K). |
| `mapSprings` | array (double/int) | `nSpr × (nDof*3)` (e.g., `nSpr × 6`) | For each torsional spring, global DOF indices for its three nodes. |

---

## Material & element properties

| Variable | Type | Size (MATLAB) | Description |
|---|---:|---:|---|
| `A` | vector (double) | `nBars × 1` | Cross-sectional area for each bar element. |
| `E` | vector (double) | `nBars × 1` | Young's modulus for each bar element. |
| `kT` | vector (double) | `nSpr × 1` | Rotational spring stiffness for each three-node spring. |
| `L` | vector (double) | `nBars × 1` | Current length of each bar (computed by `barInfo`). |
| `Lo` | vector (double) | `nBars × 1` | Original/undeformed length of each bar (set at initialization). |
| `theta` | vector (double) | `nBars × 1` | Orientation angle (rad) of each bar w.r.t. global X-axis (computed by `barInfo`). |

---

## Global system arrays & matrices

| Variable | Type | Size (MATLAB) | Description |
|---|---:|---:|---|
| `nNodes` | scalar (int) | `1×1` | Number of nodes in the structure. |
| `nDof` | scalar (int) | `1×1` | Degrees of freedom per node (2 for 2D). |
| `nBars` | scalar (int) | `1×1` | Number of bars (links). |
| `nSpr` | scalar (int) | `1×1` | Number of spring elements. |
| `nFree` | scalar (int) | `1×1` | Number of free (unrestrained) global DOFs computed by `numberDOF`. |
| `totalDof` | scalar (int) | `1×1` | `nNodes * nDof` — total number of global DOFs. |
| `kSystem` | matrix (double) | `totalDof × totalDof` | Assembled global stiffness matrix (sum of bar & spring contributions). |
| `Kff` | matrix (double) | `nFree × nFree` | Stiffness submatrix corresponding to free DOFs (used for solving). |
| `Ksf` | matrix (double) | `(totalDof - nFree) × nFree` | Coupling stiffness between restrained and free DOFs (used for reactions). |
| `kLocal` | matrix (double) | `4 × 4` | Local stiffness of a 2D axial bar element (returned by `barStiffness`). |
| `kGeom` | matrix (double) | `4 × 4` | Geometric stiffness contribution for a bar element (returned by `geomStiffness`). |
| `kSpring` | matrix (double) | `6 × 6` | Local stiffness matrix for a three‑node torsional spring (returned by `springStiffness`). |
| `T` | matrix (double) | `4 × 4` | Transformation matrix to convert local bar DOFs to global DOFs (`transformationMatrix`). |

---

## Internal force & element force arrays

| Variable | Type | Size (MATLAB) | Description |
|---|---:|---:|---|
| `intF` | vector (double) | `totalDof × 1` | System internal force vector (assembly of element internal contributions). |
| `bForce` | array (double) | `(nDof*2) × nBars` (e.g., `4 × nBars`) | Element internal bar forces (local DOF vector per bar stored column-wise). |
| `sForce` | array (double) | `(nDof*3) × nSpr` (e.g., `6 × nSpr`) | Element internal spring forces (local DOF vector per spring stored column-wise). |
| `map` | vector (double/int) | `(nDof*2)` or `(nDof*3)` | Local-to-global DOF index vector for an element during assembly. |

---

## Load & displacement vectors / histories

| Variable | Type | Size (MATLAB) | Description |
|---|---:|---:|---|
| `pSystem` | vector (double) | `totalDof × 1` | Global load vector assembled from `force` using `reshapeIdx`. |
| `pFree` | vector (double) | `nFree × 1` | Portion of `pSystem` corresponding to free DOFs. |
| `dFree` | vector (double) | `nFree × 1` | Displacements for free DOFs solved from `Kff \ pFree` (static first-order). |
| `dSystem` | vector (double) | `totalDof × 1` | Global displacement vector (free DOFs filled, restrained DOFs zeros in many routines). |
| `delta` | array (double) | `totalDof × (maxIncr+1)` | Cumulative displacement history across increments. |
| `dDelta` | array (double) | algorithm dependent (e.g. `totalDof × maxIter × maxIncr`) | Incremental correction to displacement used in iterative nonlinear solvers. |
| `P` | array (double) | `totalDof × (maxIncr+1)` | Load history across increments. |
| `dP` | array (double) | algorithm dependent (e.g. `totalDof × maxIter × maxIncr` or `totalDof × maxIncr`) | Incremental load applied during iterations/increments. |
| `Pref` | vector (double) | `totalDof × 1` | Reference system load vector assembled from `force` and `identity` (used in arc-length / load control). |

---

## Solver control & diagnostics

| Variable | Type | Size (MATLAB) | Description |
|---|---:|---:|---|
| `maxIncr` | scalar (int) | `1×1` | Maximum number of load increments for the chosen algorithm. Set different defaults per solver (e.g., 30, 100, 200). |
| `maxIter` | scalar (int) | `1×1` | Maximum number of iterations per increment for iterative nonlinear routines. |
| `lambda` | vector/array (double) | algorithm dependent | Load scaling factor(s) used by arc-length / load control algorithms. Size varies with algorithm (e.g., `maxIter × maxIncr` or `maxIncr × 1`). |
| `S` | vector (double) | `maxIncr × 1` | Stiffness parameter history used to adapt automatic load step in arc-length routine. |
| `errTol` | scalar (double) | `1×1` | Convergence tolerance for iterative solvers (e.g., `1e-6`). |
| `err` | scalar (double) | `1×1` | Current residual/error used to stop inner iterations. |
| `dirSign` | scalar (±1) | `1×1` | Direction sign used in arc-length to track load/displacement path direction. |

---

## Postprocessing & plotting variables

| Variable | Type | Size (MATLAB) | Description |
|---|---:|---:|---|
| `nodeForce` | array (double) | `nNodes × nDof` or `nNodes × nDof × (maxIncr+1)` | Nodal internal/external force (stored per increment in some routines). |
| `nodeLoc` | array (double) | `nNodes × nDof × (maxIncr+1)` | Nodal coordinates at each increment (initial coords saved at `(:,:,1)`). |
| `barThickness` | scalar (double) | `1×1` | Visual thickness used for plotting bars: `0.065 * mean(Lo)`. |
| `videoPath` | string | `1×1` | Path where the structure motion video is written. |
| `v` | VideoWriter object | object | MATLAB video writer used to save animation. |
| `xMin, yMin, xMax, yMax` | scalars (double) | `1×1` | Plotting axis bounds computed from `nodeLoc`. |

---

## Local / per-element helper variables (commonly used inside functions)

| Variable | Type | Size (MATLAB) | Description |
|---|---:|---:|---|
| `D` | array (double) | `nBars × 2` | `D = coords(links(:,2),:) - coords(links(:,1),:)` (difference vector for each bar). |
| `s1, s2` | scalar/array (double) | `nSpr × 1` | Sine of initial angles for bar pairs forming a torsional spring. |
| `c1, c2` | scalar/array (double) | `nSpr × 1` | Cosine of initial angles for bar pairs forming a torsional spring. |
| `L1, L2` | scalar (double) | `1×1` (per element) | Individual bar lengths used inside `springStiffness`. |
| `alpha1, alpha2` | scalar (double) | `1×1` | Angles computed via `atan2` used to build `B` in spring stiffness. |
| `B` | row vector (double) | `1 × (nDof*3)` (e.g., `1×6`) | Linear operator mapping global nodal displacements to spring rotation change: used to build `kSpring = kT * (B.' * B)`. |

---

## Notes & remarks

- Most numeric arrays are `double` (MATLAB default). Indices (node numbers) are stored as doubles but represent integers.
- Sizes of arrays that contain time/increment history (`delta`, `P`, `nodeLoc`, `nodeForce`) depend on solver-specific `maxIncr` and are allocated differently in each solver routine.
- `identity` and `reshapeIdx` encode the permutation between nodal `(nNodes × nDof)` ordering and global vector ordering. These must be used whenever converting between matrix/vector representations (assembly, reshaping, and plotting).
- `mapBars` and `mapSprings` give explicit mapping used for assembly; their columns refer to global DOF indices (so they are ready to index into global vectors/matrices).