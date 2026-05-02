# algebraic-graphs — ETNA workload

This directory is a fork of [snowleopard/alga](https://github.com/snowleopard/alga)
(commit `d4e43fb42db0`) with an ETNA runner overlay. It tests four Haskell
PBT backends — **QuickCheck**, **Hedgehog**, **Falsify**, **SmallCheck** —
on bug fixes mined from the upstream library's git history.

## Layout

```
algebraic-graphs/
  src/                                   # upstream library, untouched
  algebraic-graphs.cabal                 # upstream cabal file, untouched
  cabal.project                          # ours: pins GHC 9.6.6 + adds etna/
  etna.toml                              # ours: manifest (single source of truth)
  patches/                               # ours: bug-injection patches
  etna/
    etna-runner.cabal
    src/Etna/Result.hs
    src/Etna/Properties.hs               # property_<snake> :: Args -> PropertyResult
    src/Etna/Witnesses.hs                # witness_<snake>_case_<tag> :: PropertyResult
    src/Etna/Gens/{QuickCheck,Hedgehog,Falsify,SmallCheck}.hs
    app/Main.hs                          # CLI dispatcher
    test/Witnesses.hs                    # cabal test-suite: every witness must Pass on base
  BUGS.md, TASKS.md                      # generated; do not hand-edit
```

## Variants

Four bug-fix-derived variants. Each `patches/<variant>.patch` has the upstream
fix forward-direction; `git apply -R` reinstates the original bug.

| Variant | Property | Source commit | What it tests |
|---|---|---|---|
| `de_bruijn_dim_zero_8e1591a1_1` | `DeBruijnZeroSelfLoop` | [`8e1591a`](https://github.com/snowleopard/alga/commit/8e1591a1) | `deBruijn 0 _ == edge [] []` (was `vertex []`) |
| `show_no_parens_f2a9683f_1` | `ShowWithParens` | [`f2a9683f`](https://github.com/snowleopard/alga/commit/f2a9683f) | `show (Just g)` parenthesises non-trivial g |
| `minimum_mempty_pure_e0aa4bee_1` | `MinimumMonoidIdentity` | [`e0aa4be`](https://github.com/snowleopard/alga/commit/e0aa4be) | `mempty <> x == x` for `Minimum (Sum Int)` |
| `extended_zero_times_infinity_e0aa4bee_2` | `ExtendedZeroTimesInfinity` | [`e0aa4be`](https://github.com/snowleopard/alga/commit/e0aa4be) | `Finite 0 * Infinite == Finite 0` (semiring annihilator) |

The two `e0aa4bee_*` variants come from the same upstream commit; the
patches are split so each variant exercises one isolated bug.

## Running

```sh
cd workloads/Haskell/algebraic-graphs

# Confirm base passes
cabal test etna-witnesses                            # all 7 witnesses pass
cabal run etna-runner -- quickcheck All              # all 4 properties pass

# Inject one bug, re-run, restore
git apply -R --whitespace=nowarn patches/de_bruijn_dim_zero_8e1591a1_1.patch
cabal run etna-runner -- quickcheck DeBruijnZeroSelfLoop   # status: failed
git apply    --whitespace=nowarn patches/de_bruijn_dim_zero_8e1591a1_1.patch
```

The runner emits a single JSON line per call on stdout and exits 0 except
on argv-parse error. Backends supported: `etna` (witness replay),
`quickcheck`, `hedgehog`, `falsify`, `smallcheck`.

## GHC pin

`cabal.project` pins `with-compiler: /Users/akeles/.ghcup/ghc/9.6.6/bin/ghc`.
Falsify ≥ 0.2 needs `base ≥ 4.18`, which means GHC ≥ 9.6. If you don't
have 9.6.6 installed, run `ghcup install ghc 9.6.6` and adjust the
`with-compiler:` line accordingly.

## Library scope

The workload uses the full `algebraic-graphs` package. Three of the four
variants live under `Algebra.Graph.Label`'s edge-label semirings (the
mathematically rich part of the library); the fourth touches
`Algebra.Graph.deBruijn` for graph-construction. No FFI, no
`unsafePerformIO`, no module-level state — pure-Haskell semantics
throughout.
