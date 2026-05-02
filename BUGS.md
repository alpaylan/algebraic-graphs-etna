# algebraic-graphs — Injected Bugs

Algebraic graphs library (snowleopard/alga). Bug fixes mined from upstream history; modern HEAD is the base, each patch reverse-applies a fix to install the original bug.

Total mutations: 4

## Bug Index

| # | Variant | Name | Location | Injection | Fix Commit |
|---|---------|------|----------|-----------|------------|
| 1 | `de_bruijn_dim_zero_8e1591a1_1` | `debruijn_zero_no_self_loop` | `src/Algebra/Graph.hs:1032` | `patch` | `8e1591a1d4ad435f766dac4672da66d733816293` |
| 2 | `extended_zero_times_infinity_e0aa4bee_2` | `extended_zero_times_infinity` | `src/Algebra/Graph/Label.hs:284` | `patch` | `e0aa4beec88d1c1fa746603d4af8b6061e643886` |
| 3 | `minimum_mempty_pure_e0aa4bee_1` | `minimum_monoid_identity_violated` | `src/Algebra/Graph/Label.hs:325` | `patch` | `e0aa4beec88d1c1fa746603d4af8b6061e643886` |
| 4 | `show_no_parens_f2a9683f_1` | `show_adjmap_missing_parens` | `src/Algebra/Graph/AdjacencyMap.hs:176` | `patch` | `f2a9683f1c22a7e82715ac4dbb37052e12078e26` |

## Property Mapping

| Variant | Property | Witness(es) |
|---------|----------|-------------|
| `de_bruijn_dim_zero_8e1591a1_1` | `DeBruijnZeroSelfLoop` | `witness_de_bruijn_zero_self_loop_case_alphabet_two`, `witness_de_bruijn_zero_self_loop_case_empty_alphabet` |
| `extended_zero_times_infinity_e0aa4bee_2` | `ExtendedZeroTimesInfinity` | `witness_extended_zero_times_infinity_case_zero` |
| `minimum_mempty_pure_e0aa4bee_1` | `MinimumMonoidIdentity` | `witness_minimum_monoid_identity_case_five`, `witness_minimum_monoid_identity_case_seven` |
| `show_no_parens_f2a9683f_1` | `ShowWithParens` | `witness_show_with_parens_case_two_vertices`, `witness_show_with_parens_case_single_edge` |

## Framework Coverage

| Property | quickcheck | hedgehog | falsify | smallcheck |
|----------|---------:|-------:|------:|---------:|
| `DeBruijnZeroSelfLoop` | ✓ | ✓ | ✓ | ✓ |
| `ExtendedZeroTimesInfinity` | ✓ | ✓ | ✓ | ✓ |
| `MinimumMonoidIdentity` | ✓ | ✓ | ✓ | ✓ |
| `ShowWithParens` | ✓ | ✓ | ✓ | ✓ |

## Bug Details

### 1. debruijn_zero_no_self_loop

- **Variant**: `de_bruijn_dim_zero_8e1591a1_1`
- **Location**: `src/Algebra/Graph.hs:1032` (inside `deBruijn`)
- **Property**: `DeBruijnZeroSelfLoop`
- **Witness(es)**:
  - `witness_de_bruijn_zero_self_loop_case_alphabet_two` — deBruijn 0 [1,2] must equal edge [] []
  - `witness_de_bruijn_zero_self_loop_case_empty_alphabet` — deBruijn 0 [] must equal edge [] []
- **Source**: internal — Fix deBruijn graphs
  > deBruijn 0 used to return `vertex []` (a graph with one vertex, no edges). The fix returns `edge [] []` (the self-loop on the empty word), restoring the family invariant `edgeCount (deBruijn n xs) == (length (nub xs))^(n+1)` at n=0 — at n=0 this is 1, matching one self-loop.
- **Fix commit**: `8e1591a1d4ad435f766dac4672da66d733816293` — Fix deBruijn graphs
- **Invariant violated**: deBruijn 0 alphabet returns the De Bruijn graph of dimension 0, namely a single self-loop on the empty word. AdjacencyMap.edgeList of (deBruijn 0 xs) must equal [([], [])] for every alphabet xs (including []).
- **How the mutation triggers**: Reverse-applying the patch swaps `edge [] []` for `vertex []` at src/Algebra/Graph.hs:1032. The graph then has 0 edges, so edgeList = [].

### 2. extended_zero_times_infinity

- **Variant**: `extended_zero_times_infinity_e0aa4bee_2`
- **Location**: `src/Algebra/Graph/Label.hs:284` (inside `Num (Extended a)`)
- **Property**: `ExtendedZeroTimesInfinity`
- **Witness(es)**:
  - `witness_extended_zero_times_infinity_case_zero` — Finite 0 * Infinite == Finite 0 and Infinite * Finite 0 == Finite 0
- **Source**: internal — Fix various instances in Algebra.Graph.Label and add tests (#232)
  > Extended's Num instance had `(*) = liftM2 (*)`. By Extended's Monad, `Finite 0 * Infinite = Finite 0 >>= \_ -> Infinite >>= ... = Infinite`, violating the semiring annihilator law `0 * x == 0`. The fix special-cases `Finite 0 * _ = Finite 0` and `_ * Finite 0 = Finite 0` before falling back to `liftM2 (*)`.
- **Fix commit**: `e0aa4beec88d1c1fa746603d4af8b6061e643886` — Fix various instances in Algebra.Graph.Label and add tests (#232)
- **Invariant violated**: Extended's Num instance satisfies the semiring annihilator law: `Finite 0 * Infinite == Finite 0` and `Infinite * Finite 0 == Finite 0`.
- **How the mutation triggers**: Reverse-applying the patch removes the `Finite 0 * _` and `_ * Finite 0` pattern matches, leaving `(*) = liftM2 (*)`. The Monad on Extended makes `Finite 0 * Infinite` equal `Infinite`, not `Finite 0`.

### 3. minimum_monoid_identity_violated

- **Variant**: `minimum_mempty_pure_e0aa4bee_1`
- **Location**: `src/Algebra/Graph/Label.hs:325` (inside `Monoid (Minimum a)`)
- **Property**: `MinimumMonoidIdentity`
- **Witness(es)**:
  - `witness_minimum_monoid_identity_case_five` — mempty <> pure (Sum 5) must equal pure (Sum 5)
  - `witness_minimum_monoid_identity_case_seven` — mempty <> pure (Sum 7) must equal pure (Sum 7)
- **Source**: internal — Fix various instances in Algebra.Graph.Label and add tests (#232)
  > The Monoid instance for Minimum had `mempty = pure mempty` (i.e. Finite of the inner monoid's identity, which is the SMALLEST value, not the largest). Combined with `(<>) = liftA2 min`, the left-identity law `mempty <> x == x` failed: `pure (Sum 0) <> pure (Sum 5) = pure (Sum 0)`. The fix sets `mempty = noMinimum` (Infinite, the absorbing element of `min`) and `(<>) = min`.
- **Fix commit**: `e0aa4beec88d1c1fa746603d4af8b6061e643886` — Fix various instances in Algebra.Graph.Label and add tests (#232)
- **Invariant violated**: Minimum's Monoid satisfies the left-identity law: `mempty <> x == x` for every x. Concretely, `mempty <> pure (Sum n) == pure (Sum n)` for every n > 0.
- **How the mutation triggers**: Reverse-applying the patch reinstates `mempty = pure mempty` and `(<>) = liftA2 min`. For any positive n, `mempty <> pure (Sum n) = liftA2 min (pure (Sum 0)) (pure (Sum n)) = pure (Sum 0)`, which is not equal to `pure (Sum n)`.

### 4. show_adjmap_missing_parens

- **Variant**: `show_no_parens_f2a9683f_1`
- **Location**: `src/Algebra/Graph/AdjacencyMap.hs:176` (inside `Show AdjacencyMap`)
- **Property**: `ShowWithParens`
- **Witness(es)**:
  - `witness_show_with_parens_case_two_vertices` — show (Just (vertices [1,2])) must equal "Just (vertices [1,2])"
  - `witness_show_with_parens_case_single_edge` — show (Just (edges [(1,2)])) must equal "Just (edge 1 2)"
- **Source**: internal — Fix Show instances to insert parens (#142)
  > The Show instance for AdjacencyMap (and Relation, AdjacencyIntMap, etc.) defined `show` directly with `++`. This left `showsPrec p` at the default `\_ x s -> show x ++ s`, so any context that called `showsPrec p g` with `p > 10` (e.g. inside `Just g`) skipped the surrounding parens, producing unparseable output like `"Just edge 1 2"` instead of `"Just (edge 1 2)"`. The fix switches to `showsPrec` + `showParen (p > 10)`.
- **Fix commit**: `f2a9683f1c22a7e82715ac4dbb37052e12078e26` — Fix Show instances to insert parens (#142)
- **Invariant violated**: For any non-empty AdjacencyMap g (whose `show g` is more than the atomic token `"empty"`), `show (Just g)` must equal `"Just (" ++ show g ++ ")"`. This is what `showsPrec` at prec 11 buys you; `show g` alone never lies, but the surrounding context's `showsPrec` does.
- **How the mutation triggers**: Reverse-applying the patch swaps the `showsPrec p ... = showParen (p > 10) $ ...` instance for the old `show ... = "..."` instance. Default `showsPrec` then ignores the precedence and prints `Just edge 1 2` without parens.
