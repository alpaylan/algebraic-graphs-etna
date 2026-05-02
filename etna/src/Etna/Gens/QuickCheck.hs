module Etna.Gens.QuickCheck where

import qualified Test.QuickCheck as QC

import Etna.Properties
  ( DeBruijnZeroArgs(..)
  , ShowParensArgs(..)
  , MinimumIdentityArgs(..)
  , ExtendedZeroArgs(..)
  )

gen_de_bruijn_zero_self_loop :: QC.Gen DeBruijnZeroArgs
gen_de_bruijn_zero_self_loop = do
  n <- QC.choose (0, 4)
  alphabet <- QC.vectorOf n (QC.choose (0, 5))
  pure (DeBruijnZeroArgs alphabet)

gen_show_with_parens :: QC.Gen ShowParensArgs
gen_show_with_parens = do
  vN <- QC.choose (0, 4)
  eN <- QC.choose (0, 4)
  vs <- QC.vectorOf vN (QC.choose ((-3) :: Int, 3))
  es <- QC.vectorOf eN $ do
    a <- QC.choose ((-3) :: Int, 3)
    b <- QC.choose ((-3) :: Int, 3)
    pure (a, b)
  pure (ShowParensArgs vs es)

gen_minimum_monoid_identity :: QC.Gen MinimumIdentityArgs
gen_minimum_monoid_identity = do
  n <- QC.choose (1, 100)
  pure (MinimumIdentityArgs n)

gen_extended_zero_times_infinity :: QC.Gen ExtendedZeroArgs
gen_extended_zero_times_infinity = do
  -- Bias toward 0: exercise the buggy branch with high probability.
  n <- QC.frequency
         [ (8, pure 0)
         , (1, QC.choose (1, 5))
         , (1, QC.choose (-5, -1))
         ]
  pure (ExtendedZeroArgs n)
