module Etna.Gens.Hedgehog where

import           Hedgehog          (Gen)
import qualified Hedgehog.Gen      as Gen
import qualified Hedgehog.Range    as Range

import Etna.Properties
  ( DeBruijnZeroArgs(..)
  , ShowParensArgs(..)
  , MinimumIdentityArgs(..)
  , ExtendedZeroArgs(..)
  )

-- | Library-faithful generator for the deBruijn-zero property: alphabet
-- length up to the property's discard envelope (6), elements in the
-- upstream-typical @[-100, 100]@ range.
gen_de_bruijn_zero_self_loop :: Gen DeBruijnZeroArgs
gen_de_bruijn_zero_self_loop = do
  alphabet <- Gen.list (Range.linear 0 6)
                       (Gen.int (Range.linearFrom 0 (-100) 100))
  pure (DeBruijnZeroArgs alphabet)

-- | Library-faithful generator for the show-with-parens property.
-- Lengths 0..5, vertices/edges in @[-3, 3]@ — matches the property's
-- discard envelope so every draw is library-faithful.
gen_show_with_parens :: Gen ShowParensArgs
gen_show_with_parens = do
  vs <- Gen.list (Range.linear 0 5) (Gen.int (Range.linearFrom 0 (-3) 3))
  es <- Gen.list (Range.linear 0 5) $ do
    a <- Gen.int (Range.linearFrom 0 (-3) 3)
    b <- Gen.int (Range.linearFrom 0 (-3) 3)
    pure (a, b)
  pure (ShowParensArgs vs es)

-- | Library-faithful generator for the minimum-monoid-identity property:
-- positive integers up to the discard envelope (1000).
gen_minimum_monoid_identity :: Gen MinimumIdentityArgs
gen_minimum_monoid_identity = do
  n <- Gen.int (Range.linear 1 1000)
  pure (MinimumIdentityArgs n)

-- | Library-faithful generator for the extended-zero-times-infinity
-- property: bias toward 0 (the bug-triggering value) while sampling
-- non-zero values across @[-100, 100]@ to exercise the discard branch.
gen_extended_zero_times_infinity :: Gen ExtendedZeroArgs
gen_extended_zero_times_infinity = do
  n <- Gen.frequency
         [ (8, pure 0)
         , (1, Gen.int (Range.linear 1 100))
         , (1, Gen.int (Range.linear (-100) (-1)))
         ]
  pure (ExtendedZeroArgs n)
