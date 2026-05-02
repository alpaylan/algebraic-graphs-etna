# algebraic-graphs — ETNA Tasks

Total tasks: 16

## Task Index

| Task | Variant | Framework | Property | Witness |
|------|---------|-----------|----------|---------|
| 001 | `de_bruijn_dim_zero_8e1591a1_1` | quickcheck | `DeBruijnZeroSelfLoop` | `witness_de_bruijn_zero_self_loop_case_alphabet_two` |
| 002 | `de_bruijn_dim_zero_8e1591a1_1` | hedgehog | `DeBruijnZeroSelfLoop` | `witness_de_bruijn_zero_self_loop_case_alphabet_two` |
| 003 | `de_bruijn_dim_zero_8e1591a1_1` | falsify | `DeBruijnZeroSelfLoop` | `witness_de_bruijn_zero_self_loop_case_alphabet_two` |
| 004 | `de_bruijn_dim_zero_8e1591a1_1` | smallcheck | `DeBruijnZeroSelfLoop` | `witness_de_bruijn_zero_self_loop_case_alphabet_two` |
| 005 | `extended_zero_times_infinity_e0aa4bee_2` | quickcheck | `ExtendedZeroTimesInfinity` | `witness_extended_zero_times_infinity_case_zero` |
| 006 | `extended_zero_times_infinity_e0aa4bee_2` | hedgehog | `ExtendedZeroTimesInfinity` | `witness_extended_zero_times_infinity_case_zero` |
| 007 | `extended_zero_times_infinity_e0aa4bee_2` | falsify | `ExtendedZeroTimesInfinity` | `witness_extended_zero_times_infinity_case_zero` |
| 008 | `extended_zero_times_infinity_e0aa4bee_2` | smallcheck | `ExtendedZeroTimesInfinity` | `witness_extended_zero_times_infinity_case_zero` |
| 009 | `minimum_mempty_pure_e0aa4bee_1` | quickcheck | `MinimumMonoidIdentity` | `witness_minimum_monoid_identity_case_five` |
| 010 | `minimum_mempty_pure_e0aa4bee_1` | hedgehog | `MinimumMonoidIdentity` | `witness_minimum_monoid_identity_case_five` |
| 011 | `minimum_mempty_pure_e0aa4bee_1` | falsify | `MinimumMonoidIdentity` | `witness_minimum_monoid_identity_case_five` |
| 012 | `minimum_mempty_pure_e0aa4bee_1` | smallcheck | `MinimumMonoidIdentity` | `witness_minimum_monoid_identity_case_five` |
| 013 | `show_no_parens_f2a9683f_1` | quickcheck | `ShowWithParens` | `witness_show_with_parens_case_two_vertices` |
| 014 | `show_no_parens_f2a9683f_1` | hedgehog | `ShowWithParens` | `witness_show_with_parens_case_two_vertices` |
| 015 | `show_no_parens_f2a9683f_1` | falsify | `ShowWithParens` | `witness_show_with_parens_case_two_vertices` |
| 016 | `show_no_parens_f2a9683f_1` | smallcheck | `ShowWithParens` | `witness_show_with_parens_case_two_vertices` |

## Witness Catalog

- `witness_de_bruijn_zero_self_loop_case_alphabet_two` — deBruijn 0 [1,2] must equal edge [] []
- `witness_de_bruijn_zero_self_loop_case_empty_alphabet` — deBruijn 0 [] must equal edge [] []
- `witness_extended_zero_times_infinity_case_zero` — Finite 0 * Infinite == Finite 0 and Infinite * Finite 0 == Finite 0
- `witness_minimum_monoid_identity_case_five` — mempty <> pure (Sum 5) must equal pure (Sum 5)
- `witness_minimum_monoid_identity_case_seven` — mempty <> pure (Sum 7) must equal pure (Sum 7)
- `witness_show_with_parens_case_two_vertices` — show (Just (vertices [1,2])) must equal "Just (vertices [1,2])"
- `witness_show_with_parens_case_single_edge` — show (Just (edges [(1,2)])) must equal "Just (edge 1 2)"
