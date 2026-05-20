module Etna.Gens.Falsify where

import qualified Test.Falsify.Generator as F
import qualified Test.Falsify.Range     as FR

import Etna.Properties
  ( DeBruijnZeroArgs(..)
  , ShowParensArgs(..)
  , MinimumIdentityArgs(..)
  , ExtendedZeroArgs(..)
  )

-- | Library-faithful generator for the deBruijn-zero property: alphabet
-- length up to 6 (the property's discard envelope), elements in the
-- upstream-typical @[-100, 100]@ vertex range.
gen_de_bruijn_zero_self_loop :: F.Gen DeBruijnZeroArgs
gen_de_bruijn_zero_self_loop = do
  alphabet <- F.list (FR.between (0 :: Word, 6))
                     (F.inRange (FR.between ((-100) :: Int, 100)))
  pure (DeBruijnZeroArgs alphabet)

-- | Library-faithful generator for the show-with-parens property: lengths
-- 0..5, elements in @[-3, 3]@ — matches the property's discard envelope.
gen_show_with_parens :: F.Gen ShowParensArgs
gen_show_with_parens = do
  vs <- F.list (FR.between (0 :: Word, 5))
               (F.inRange (FR.between (-3 :: Int, 3)))
  es <- F.list (FR.between (0 :: Word, 5)) $ do
    a <- F.inRange (FR.between (-3 :: Int, 3))
    b <- F.inRange (FR.between (-3 :: Int, 3))
    pure (a, b)
  pure (ShowParensArgs vs es)

-- | Library-faithful generator for the minimum-monoid-identity property:
-- positive integers up to the discard envelope (1000).
gen_minimum_monoid_identity :: F.Gen MinimumIdentityArgs
gen_minimum_monoid_identity = do
  n <- F.inRange (FR.between (1 :: Int, 1000))
  pure (MinimumIdentityArgs n)

-- | Library-faithful generator for the extended-zero-times-infinity
-- property. Falsify shrinks toward the lower endpoint of @FR.between@, so
-- choosing @[0, 100]@ keeps 0 (the bug trigger) as the shrink target while
-- exercising non-zero values across the upstream-typical envelope.
gen_extended_zero_times_infinity :: F.Gen ExtendedZeroArgs
gen_extended_zero_times_infinity = do
  n <- F.inRange (FR.between (0 :: Int, 100))
  pure (ExtendedZeroArgs n)
