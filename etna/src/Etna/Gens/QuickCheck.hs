module Etna.Gens.QuickCheck where

import qualified Test.QuickCheck as QC

import Etna.Properties
  ( DeBruijnZeroArgs(..)
  , ShowParensArgs(..)
  , MinimumIdentityArgs(..)
  , ExtendedZeroArgs(..)
  )

-- | Library-faithful generator for the deBruijn-zero property.
-- The property holds for /every/ alphabet, including @[]@; the bug is in the
-- @deBruijn 0@ branch and triggers regardless of the alphabet's contents. We
-- emit alphabets up to the property's discard envelope (length 6) with
-- elements drawn from the upstream-typical @[-100, 100]@ vertex range.
gen_de_bruijn_zero_self_loop :: QC.Gen DeBruijnZeroArgs
gen_de_bruijn_zero_self_loop = do
  n <- QC.choose (0 :: Int, 6)
  alphabet <- QC.vectorOf n (QC.choose ((-100) :: Int, 100))
  pure (DeBruijnZeroArgs alphabet)

-- | Library-faithful generator for the show-with-parens property.
-- Vertices and edges are drawn within the property's discard envelope
-- (lengths 0..5, elements in @[-3, 3]@). Within that envelope the bug
-- triggers on any non-empty graph whose @show@ output is more than
-- @"empty"@.
gen_show_with_parens :: QC.Gen ShowParensArgs
gen_show_with_parens = do
  vN <- QC.choose (0 :: Int, 5)
  eN <- QC.choose (0 :: Int, 5)
  vs <- QC.vectorOf vN (QC.choose ((-3) :: Int, 3))
  es <- QC.vectorOf eN $ do
    a <- QC.choose ((-3) :: Int, 3)
    b <- QC.choose ((-3) :: Int, 3)
    pure (a, b)
  pure (ShowParensArgs vs es)

-- | Library-faithful generator for the minimum-monoid-identity property.
-- The property's discard envelope is @1 <= n <= 1000@; the bug triggers on
-- any positive @n@. Widen to the full envelope so the failure surfaces on
-- arbitrary positive values rather than a clipped @[1, 100]@ slice.
gen_minimum_monoid_identity :: QC.Gen MinimumIdentityArgs
gen_minimum_monoid_identity = do
  n <- QC.choose (1 :: Int, 1000)
  pure (MinimumIdentityArgs n)

-- | Library-faithful generator for the extended-zero-times-infinity
-- property. Only @n == 0@ avoids 'Discard'; we bias toward 0 (the bug
-- trigger) while still occasionally drawing non-zero values from the
-- typical upstream @[-100, 100]@ envelope to exercise the discard branch.
gen_extended_zero_times_infinity :: QC.Gen ExtendedZeroArgs
gen_extended_zero_times_infinity = do
  n <- QC.frequency
         [ (8, pure 0)
         , (1, QC.choose (1 :: Int, 100))
         , (1, QC.choose ((-100) :: Int, -1))
         ]
  pure (ExtendedZeroArgs n)
