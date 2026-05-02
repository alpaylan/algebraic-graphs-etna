module Etna.Witnesses where

import Etna.Properties
import Etna.Result

------------------------------------------------------------------------------
-- DeBruijnZeroSelfLoop
------------------------------------------------------------------------------

-- | deBruijn 0 [1,2] should equal edge [] [].
witness_de_bruijn_zero_self_loop_case_alphabet_two :: PropertyResult
witness_de_bruijn_zero_self_loop_case_alphabet_two =
  property_de_bruijn_zero_self_loop (DeBruijnZeroArgs [1, 2])

-- | deBruijn 0 [] should still equal edge [] []. The "n > 0 ==> deBruijn n
-- [] == empty" guard exempts dimension 0 from the empty-alphabet case.
witness_de_bruijn_zero_self_loop_case_empty_alphabet :: PropertyResult
witness_de_bruijn_zero_self_loop_case_empty_alphabet =
  property_de_bruijn_zero_self_loop (DeBruijnZeroArgs [])

------------------------------------------------------------------------------
-- ShowWithParens
------------------------------------------------------------------------------

-- | A two-vertex graph: show g = "vertices [1,2]"; show (Just g) must
-- equal "Just (vertices [1,2])".
witness_show_with_parens_case_two_vertices :: PropertyResult
witness_show_with_parens_case_two_vertices =
  property_show_with_parens (ShowParensArgs [1, 2] [])

-- | A single-edge graph: show g = "edge 1 2"; show (Just g) must equal
-- "Just (edge 1 2)".
witness_show_with_parens_case_single_edge :: PropertyResult
witness_show_with_parens_case_single_edge =
  property_show_with_parens (ShowParensArgs [] [(1, 2)])

------------------------------------------------------------------------------
-- MinimumMonoidIdentity
------------------------------------------------------------------------------

witness_minimum_monoid_identity_case_five :: PropertyResult
witness_minimum_monoid_identity_case_five =
  property_minimum_monoid_identity (MinimumIdentityArgs 5)

witness_minimum_monoid_identity_case_seven :: PropertyResult
witness_minimum_monoid_identity_case_seven =
  property_minimum_monoid_identity (MinimumIdentityArgs 7)

------------------------------------------------------------------------------
-- ExtendedZeroTimesInfinity
------------------------------------------------------------------------------

witness_extended_zero_times_infinity_case_zero :: PropertyResult
witness_extended_zero_times_infinity_case_zero =
  property_extended_zero_times_infinity (ExtendedZeroArgs 0)
