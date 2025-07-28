# QIToolbox

QIToolbox is a small MATLAB research toolbox for constructing Bell-type inequality tensors and exhaustively computing deterministic bounds with zero or one bit of communication from Alice to Bob.

The repository currently includes:

- parallel-repetition CHSH winning tensors;
- one- and two-round Hardy inequalities, including a one-round reformulation;
- the one-round Magic Square winning tensor;
- exhaustive 0-bit and 1-bit bound searches;
- optional NPA quantum-bound examples using Moment and CVX.

## Requirements

### Core calculations

- MATLAB R2021b or later.
- No additional toolbox is required for serial execution.
- Parallel Computing Toolbox is optional and is used only when `UseParallel` is explicitly set to `true`.

### Optional quantum examples

The quantum sections of the Hardy examples require:

- [Moment v0.9.0-beta](https://github.com/ajpgarner/moment/releases/tag/v0.9.0-beta);
- [CVX 2.2](https://cvxr.com/cvx/download/).

Moment v0.9.0-beta documents support for CVX 2.2, not CVX 3. Install both projects according to their own instructions and make sure `LocalityScenario` and `cvx_begin` are on the MATLAB path. The local/1-bit calculations still run when these optional dependencies are absent; the quantum section is skipped with a warning.

## Setup

Clone the repository and run its startup script:

```matlab
run('/absolute/path/to/QIToolbox/startup.m')
```

`startup.m` resolves paths relative to itself, so it works from any current directory. It adds `src/` and `examples/`, including their subdirectories, to the MATLAB path for the current session.

## Quick start

Compute the one-round Magic Square local bound:

```matlab
run('/absolute/path/to/QIToolbox/startup.m')
[I, dims] = magic_ineq_r1();
[maxValue, bestStrategies] = L0bit_bound(I, dims);
```

The expected value is `8`.

Enable parallel execution only when Parallel Computing Toolbox is available:

```matlab
[maxValue, bestStrategies] = L0bit_bound(I, dims, 'UseParallel', true);
```

## API and tensor convention

Every inequality generator returns:

```matlab
[I, dims]
```

`dims` contains the positive integer fields `mA`, `mB`, `oA`, `oB`, and `n`. The coefficient tensor has size

```text
[oA^n, oB^n, mA^n, mB^n]
```

corresponding to Alice outputs, Bob outputs, Alice inputs, and Bob inputs. Per-round vectors are flattened in MATLAB column-major order: the first round changes fastest.

### `L0bit_bound`

```matlab
[maxValue, bestStrategies] = L0bit_bound(I, dims)
```

Searches deterministic local strategies without communication. `bestStrategies` contains:

- `f`: Alice's output for each flattened Alice input;
- `g`: Bob's output for each flattened Bob input.

### `L1bit_bound`

```matlab
[maxValue, bestStrategies] = L1bit_bound(I, dims)
```

Searches deterministic strategies with one bit sent from Alice to Bob. `bestStrategies` contains:

- `h`: Alice's message (`0` or `1`) for each flattened Alice input;
- `f`: Alice's output for each flattened Alice input;
- `g_c0`, `g_c1`: Bob's responses for each message value.

Both functions validate `dims` and the tensor size. Serial execution is the default.

## Reproduction examples

After running `startup.m`, run the scripts below from MATLAB:

| Script | Calculation | Expected deterministic bound |
| --- | --- | ---: |
| `examples/use_inequalities/chsh_rn.m` | CHSH r1, 1 bit | 4 |
| `examples/use_inequalities/magic_r1.m` | Magic Square r1, 0 bit | 8 |
| `examples/use_inequalities/hardy/hardy_r1.m` | Hardy r1, 0 bit | 0 |
| `examples/use_inequalities/hardy/hardy_r2.m` | Hardy r2, 1 bit | 4 |
| `examples/use_inequalities/hardy/hardy_r2_reformulation.m` | Hardy r2 reformulation, 1 bit | 4 |

The Hardy scripts continue with an optional Moment/CVX quantum calculation when both dependencies are available.

## Performance limits

These are exhaustive searches, not scalable optimization algorithms. Their strategy spaces grow as

```text
L0 Bob strategies: (oB^n)^(mB^n)
L1 canonical Alice strategies: 2^(mA^n - 1) * (oA^n)^(mA^n)
```

QIToolbox rejects strategy counts beyond MATLAB's reliable integer indexing range, but smaller cases can still exceed available time or memory. Start with the included one- and two-round examples. Use `UseParallel=true` only after confirming that the serial result is correct for a small case.

## Repository layout

```text
src/L0bit/          0-bit exhaustive bound
src/L1bit/          1-bit exhaustive bound
src/inequalities/   CHSH, Hardy, and Magic Square tensors
src/utils/          shared tensor/strategy indexing
examples/           local, 1-bit, and optional quantum reproductions
startup.m           session path setup
```

## Feedback

Please use the repository's GitHub issue tracker for reproducibility problems or incorrect bounds. Include the MATLAB version, toolbox versions, example name, parameters, and complete error/output text.

## Citation and license

No formal citation file is currently provided. Until one is added, cite the repository URL and the exact commit used for a result.

**No software license is currently granted.** The source is publicly visible, but reuse, modification, and redistribution are not authorized by an open-source license. Contact the repository owner if permission is required.
