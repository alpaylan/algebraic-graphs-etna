module Etna.Gens.Falsify where

import qualified Test.Falsify.Generator as F
import qualified Test.Falsify.Range     as FR

import Etna.Properties
  ( DeBruijnZeroArgs(..)
  , ShowParensArgs(..)
  , MinimumIdentityArgs(..)
  , ExtendedZeroArgs(..)
  )

gen_de_bruijn_zero_self_loop :: F.Gen DeBruijnZeroArgs
gen_de_bruijn_zero_self_loop = do
  alphabet <- F.list (FR.between (0 :: Word, 4))
                     (F.inRange (FR.between (0 :: Int, 5)))
  pure (DeBruijnZeroArgs alphabet)

gen_show_with_parens :: F.Gen ShowParensArgs
gen_show_with_parens = do
  vs <- F.list (FR.between (0 :: Word, 4))
               (F.inRange (FR.between (-3 :: Int, 3)))
  es <- F.list (FR.between (0 :: Word, 4)) $ do
    a <- F.inRange (FR.between (-3 :: Int, 3))
    b <- F.inRange (FR.between (-3 :: Int, 3))
    pure (a, b)
  pure (ShowParensArgs vs es)

gen_minimum_monoid_identity :: F.Gen MinimumIdentityArgs
gen_minimum_monoid_identity = do
  n <- F.inRange (FR.between (1 :: Int, 100))
  pure (MinimumIdentityArgs n)

gen_extended_zero_times_infinity :: F.Gen ExtendedZeroArgs
gen_extended_zero_times_infinity = do
  -- Falsify shrinks toward the lower endpoint of FR.between, so 0 is the
  -- shrink target — perfect for hitting the buggy branch.
  n <- F.inRange (FR.between (0 :: Int, 4))
  pure (ExtendedZeroArgs n)
