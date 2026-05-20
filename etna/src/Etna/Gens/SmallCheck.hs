{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Etna.Gens.SmallCheck where

import qualified Test.SmallCheck.Series as SC

import Etna.Properties
  ( DeBruijnZeroArgs(..)
  , ShowParensArgs(..)
  , MinimumIdentityArgs(..)
  , ExtendedZeroArgs(..)
  )

-- | Library-faithful enumeration: alphabets of length 0..min(d, 6) with
-- elements drawn from a small symmetric @Int@ range. SmallCheck explores
-- by depth; bounding alphabet length at the discard envelope (6) keeps
-- enumeration bounded while exposing the bug across many alphabets.
series_de_bruijn_zero_self_loop :: Monad m => SC.Series m DeBruijnZeroArgs
series_de_bruijn_zero_self_loop = do
  n <- SC.generate (\d -> [0 .. min d 6])
  alphabet <- replicateA n (SC.generate (\d -> [-(min d 5) .. min d 5]))
  pure (DeBruijnZeroArgs alphabet)
  where
    replicateA :: Applicative f => Int -> f a -> f [a]
    replicateA 0 _ = pure []
    replicateA k f = (:) <$> f <*> replicateA (k - 1) f

-- | Library-faithful enumeration of small AdjacencyMap configurations.
-- Vertex/edge counts up to 5 (the property's discard envelope); elements
-- range over @[-3, 3]@ matching the discard envelope. Depth bounds keep
-- enumeration tractable while reaching every shape that triggers the bug.
series_show_with_parens :: Monad m => SC.Series m ShowParensArgs
series_show_with_parens = do
  vN <- SC.generate (\d -> [0 .. min d 5])
  eN <- SC.generate (\d -> [0 .. min d 5])
  vs <- replicateA vN (SC.generate (\d -> [-(min d 3) .. min d 3]))
  es <- replicateA eN $ do
    a <- SC.generate (\d -> [-(min d 3) .. min d 3])
    b <- SC.generate (\d -> [-(min d 3) .. min d 3])
    pure (a, b)
  pure (ShowParensArgs vs es)
  where
    replicateA :: Applicative f => Int -> f a -> f [a]
    replicateA 0 _ = pure []
    replicateA k f = (:) <$> f <*> replicateA (k - 1) f

-- | Library-faithful enumeration: positive integers up to the property's
-- discard envelope (1000). SmallCheck depth scales naturally; @max 1
-- (d + 1)@ guarantees we always emit at least one positive value, while
-- larger depths reach the full @[1, 1000]@ envelope.
series_minimum_monoid_identity :: Monad m => SC.Series m MinimumIdentityArgs
series_minimum_monoid_identity = do
  n <- SC.generate (\d -> [1 .. min 1000 (max 1 (d + 1))])
  pure (MinimumIdentityArgs n)

-- | The bug only triggers at @n == 0@; non-zero values are 'Discard'ed by
-- the property. We sample @0@ at every depth and surround it with a few
-- non-zero values (which the property discards) to exercise the discard
-- branch on backends that don't special-case it.
series_extended_zero_times_infinity :: Monad m => SC.Series m ExtendedZeroArgs
series_extended_zero_times_infinity = do
  n <- SC.generate (\d -> 0 : [-(min d 5) .. min d 5])
  pure (ExtendedZeroArgs n)
