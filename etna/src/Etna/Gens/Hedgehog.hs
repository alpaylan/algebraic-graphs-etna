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

gen_de_bruijn_zero_self_loop :: Gen DeBruijnZeroArgs
gen_de_bruijn_zero_self_loop = do
  alphabet <- Gen.list (Range.linear 0 4) (Gen.int (Range.linear 0 5))
  pure (DeBruijnZeroArgs alphabet)

gen_show_with_parens :: Gen ShowParensArgs
gen_show_with_parens = do
  vs <- Gen.list (Range.linear 0 4) (Gen.int (Range.linearFrom 0 (-3) 3))
  es <- Gen.list (Range.linear 0 4) $ do
    a <- Gen.int (Range.linearFrom 0 (-3) 3)
    b <- Gen.int (Range.linearFrom 0 (-3) 3)
    pure (a, b)
  pure (ShowParensArgs vs es)

gen_minimum_monoid_identity :: Gen MinimumIdentityArgs
gen_minimum_monoid_identity = do
  n <- Gen.int (Range.linear 1 100)
  pure (MinimumIdentityArgs n)

gen_extended_zero_times_infinity :: Gen ExtendedZeroArgs
gen_extended_zero_times_infinity = do
  -- Bias toward 0 by frequency.
  n <- Gen.frequency
         [ (8, pure 0)
         , (1, Gen.int (Range.linear 1 5))
         , (1, Gen.int (Range.linear (-5) (-1)))
         ]
  pure (ExtendedZeroArgs n)
