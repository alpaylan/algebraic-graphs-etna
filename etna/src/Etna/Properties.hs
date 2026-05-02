{-# LANGUAGE ScopedTypeVariables #-}
module Etna.Properties where

import Etna.Result

import qualified Algebra.Graph              as G
import qualified Algebra.Graph.AdjacencyMap as AM
import           Algebra.Graph.Label
  ( Minimum, noMinimum
  , NonNegative, unsafeFinite, infinite, getFinite
  )
import           Data.Monoid                (Sum(..))

------------------------------------------------------------------------------
-- Variant 1: de_bruijn_dim_zero_8e1591a1_1
-- "Fix deBruijn graphs"
--
-- The buggy 'deBruijn' returns @vertex []@ for dimension 0, which has
-- @edgeCount = 0@. The fixed code returns @edge [] []@, a self-loop on the
-- empty word with @edgeCount = 1@ — matching the De Bruijn invariant
-- @edgeCount (deBruijn n xs) == (length (nub xs))^(n + 1)@ at @n=0@.
------------------------------------------------------------------------------

-- | Generator emits a small alphabet @[Int]@. The dimension is fixed at 0
-- (the only case the bug touches); other dimensions take @>= 1@ symbols
-- and so don't share the same buggy branch.
newtype DeBruijnZeroArgs = DeBruijnZeroArgs { dbAlphabet :: [Int] }
  deriving (Show, Eq)

-- | Property: @deBruijn 0 alphabet@ is the graph @edge [] []@ for every
-- alphabet (including @[]@) — a single self-loop on the empty word.
property_de_bruijn_zero_self_loop :: DeBruijnZeroArgs -> PropertyResult
property_de_bruijn_zero_self_loop (DeBruijnZeroArgs alphabet)
  | length alphabet > 6 = Discard
  | otherwise =
      let g  :: G.Graph [Int]
          g  = G.deBruijn 0 alphabet
          am = G.foldg AM.empty AM.vertex AM.overlay AM.connect g
          es = AM.edgeList am
      in case es of
           [(x, y)] | x == [] && y == [] -> Pass
           _ -> Fail $
             "deBruijn 0 " ++ show alphabet ++ ": edgeList = " ++ show es ++
             "; expected [([],[])]"

------------------------------------------------------------------------------
-- Variant 2: show_no_parens_f2a9683f_1
-- "Fix Show instances to insert parens (#142)"
--
-- The buggy Show instance defined `show` directly with `++`, falling back
-- to the default @showsPrec _ x s = show x ++ s@. As a result, any context
-- that called @showsPrec p g@ with @p > 10@ — e.g. rendering @Just g@ —
-- skipped the surrounding parens, producing @"Just edge 1 2"@ instead of
-- @"Just (edge 1 2)"@. The fixed instance defines @showsPrec@ with
-- @showParen (p > 10)@, so nested contexts get the parens they need.
------------------------------------------------------------------------------

-- | Generator produces a list of vertex/edge specifications used to build
-- a small adjacency-map graph. We render @show (Just g)@ and check that
-- it matches @"Just (" ++ show g ++ ")"@ for non-trivial @g@.
data ShowParensArgs = ShowParensArgs
  { spVertices :: ![Int]
  , spEdges    :: ![(Int, Int)]
  } deriving (Show, Eq)

-- | Property: for any non-empty 'AdjacencyMap', @show (Just g)@ wraps
-- @show g@ in parens (because @showsPrec@ at prec 11 must add them).
property_show_with_parens :: ShowParensArgs -> PropertyResult
property_show_with_parens (ShowParensArgs vs es)
  | length vs > 5 = Discard
  | length es > 5 = Discard
  | any (\(a, b) -> a < (-3) || a > 3 || b < (-3) || b > 3) es = Discard
  | any (\v -> v < (-3) || v > 3) vs = Discard
  | otherwise =
      let g :: AM.AdjacencyMap Int
          g = AM.overlay (AM.vertices vs) (AM.edges es)
          gShown    = show g
          justShown = show (Just g)
      in if gShown == "empty"
         then Discard  -- "Just empty" is atomic; default showsPrec is fine.
         else
           let expected = "Just (" ++ gShown ++ ")"
           in if justShown == expected
              then Pass
              else Fail $
                "show g = " ++ show gShown ++
                "; show (Just g) = " ++ show justShown ++
                "; expected " ++ show expected

------------------------------------------------------------------------------
-- Variant 3: minimum_mempty_pure_e0aa4bee_1
-- "Fix various instances in Algebra.Graph.Label and add tests (#232)"
-- (Subset isolated to the 'Minimum' Monoid identity bug.)
--
-- The buggy 'Minimum' Monoid had @mempty = pure mempty@ (i.e. @Finite (a's
-- mempty)@) and @(<>) = liftA2 min@. For most non-zero @a@ values, this
-- violates the left-identity law @mempty <> x == x@: with @x = pure (Sum 5)@
-- the buggy code returns @pure (Sum 0)@ instead of @x@. The fix sets
-- @mempty = noMinimum@ (i.e. @Infinite@) and @(<>) = min@.
------------------------------------------------------------------------------

-- | A positive integer used to construct @x = Minimum (pure (Sum n))@. The
-- monoid identity must hold for every @x@; we restrict to positive @n@
-- because @n = 0@ is the unit of the underlying @Sum@ monoid and so the
-- buggy and fixed @mempty <> x@ both reduce to the same value.
newtype MinimumIdentityArgs = MinimumIdentityArgs { miValue :: Int }
  deriving (Show, Eq)

-- | Property: @mempty <> x == x@ for @x = Minimum (pure (Sum n))@ with
-- @n > 0@. Holds iff @mempty :: Minimum (Sum Int)@ is @noMinimum@ (the
-- absorbing element of @<> = min@), not the underlying monoid's @mempty@
-- (which would be @pure (Sum 0)@, smaller than any positive value).
property_minimum_monoid_identity :: MinimumIdentityArgs -> PropertyResult
property_minimum_monoid_identity (MinimumIdentityArgs n)
  | n <= 0    = Discard
  | n > 1000  = Discard
  | otherwise =
      let x   = pure (Sum n) :: Minimum (Sum Int)
          lhs = mempty <> x
      in if lhs == x
         then Pass
         else Fail $
           "mempty <> Minimum(pure (Sum " ++ show n ++ ")) = " ++ show lhs ++
           "; expected " ++ show x

------------------------------------------------------------------------------
-- Variant 4: extended_zero_times_infinity_e0aa4bee_2
-- "Fix various instances in Algebra.Graph.Label and add tests (#232)"
-- (Subset isolated to the 'Extended' annihilating-zero bug.)
--
-- The buggy 'Extended' Num instance had @(*) = liftM2 (*)@. By
-- 'Extended''s Monad, @Finite 0 * Infinite = Finite 0 >>= \\_ -> Infinite >>= ...
-- = Infinite@, violating the semiring law @0 * x == 0@. The fix special-cases
-- @Finite 0 * _ = Finite 0@ and @_ * Finite 0 = Finite 0@.
--
-- Note: @Extended@ itself is not exported from "Algebra.Graph.Label", but
-- @NonNegative@ — a newtype around @Extended@ — is. The 'NonNegative' 'Num'
-- instance @coerce@s to the underlying @Extended@ multiplication, so the
-- bug is observable through the public @unsafeFinite@ / @infinite@ /
-- @getFinite@ surface.
------------------------------------------------------------------------------

-- | The arg is an integer; if @= 0@ we exercise the buggy branch (zero
-- times infinity should be zero). Other values land in the unaffected
-- branch and get discarded — keeps the property a clean detector of the
-- specific bug rather than a tautology over all 'NonNegative' values.
newtype ExtendedZeroArgs = ExtendedZeroArgs { ezSeed :: Int }
  deriving (Show, Eq)

-- | Property: @unsafeFinite 0 * infinite == unsafeFinite 0@ and the
-- symmetric case. Holds iff the @Finite 0@ annihilator pattern matches
-- were added to 'Extended''s @Num@ instance.
property_extended_zero_times_infinity :: ExtendedZeroArgs -> PropertyResult
property_extended_zero_times_infinity (ExtendedZeroArgs n)
  | n /= 0 = Discard
  | otherwise =
      let zL = unsafeFinite (0 :: Int) * infinite :: NonNegative Int
          zR = infinite * unsafeFinite (0 :: Int) :: NonNegative Int
      in case (getFinite zL, getFinite zR) of
           (Just 0, Just 0) -> Pass
           _ -> Fail $
             "unsafeFinite 0 * infinite = " ++ show zL ++
             "; infinite * unsafeFinite 0 = " ++ show zR ++
             "; expected unsafeFinite 0 in both"
