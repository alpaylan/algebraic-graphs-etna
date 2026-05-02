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

-- | Bounded enumeration: alphabets of length 0..d with elements 0..1.
series_de_bruijn_zero_self_loop :: Monad m => SC.Series m DeBruijnZeroArgs
series_de_bruijn_zero_self_loop = do
  n <- SC.generate (\d -> [0 .. min d 3])
  alphabet <- replicateA n (SC.generate (\_ -> [0, 1]))
  pure (DeBruijnZeroArgs alphabet)
  where
    replicateA :: Applicative f => Int -> f a -> f [a]
    replicateA 0 _ = pure []
    replicateA k f = (:) <$> f <*> replicateA (k - 1) f

-- | A small set of vertex/edge configurations enumerated by depth.
series_show_with_parens :: Monad m => SC.Series m ShowParensArgs
series_show_with_parens = do
  vN <- SC.generate (\d -> [0 .. min d 2])
  eN <- SC.generate (\d -> [0 .. min d 2])
  vs <- replicateA vN (SC.generate (\_ -> [0, 1]))
  es <- replicateA eN $ do
    a <- SC.generate (\_ -> [0, 1])
    b <- SC.generate (\_ -> [0, 1])
    pure (a, b)
  pure (ShowParensArgs vs es)
  where
    replicateA :: Applicative f => Int -> f a -> f [a]
    replicateA 0 _ = pure []
    replicateA k f = (:) <$> f <*> replicateA (k - 1) f

-- | SmallCheck's default Int series enumerates 0, 1, -1, 2, -2, ...
-- up to depth d. Filter out non-positives in the property's Discard branch.
series_minimum_monoid_identity :: Monad m => SC.Series m MinimumIdentityArgs
series_minimum_monoid_identity = do
  n <- SC.generate (\d -> [1 .. max 1 (d + 1)])
  pure (MinimumIdentityArgs n)

-- | The bug only triggers at @n == 0@; SmallCheck's depth-0 series for Int
-- already yields 0, so this trivially exercises the bug at minimum depth.
series_extended_zero_times_infinity :: Monad m => SC.Series m ExtendedZeroArgs
series_extended_zero_times_infinity = do
  n <- SC.generate (\_ -> [0])
  pure (ExtendedZeroArgs n)
