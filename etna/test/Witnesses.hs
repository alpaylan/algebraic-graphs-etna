module Main where

import Etna.Result    (PropertyResult(..))
import Etna.Witnesses
  ( witness_de_bruijn_zero_self_loop_case_alphabet_two
  , witness_de_bruijn_zero_self_loop_case_empty_alphabet
  , witness_show_with_parens_case_two_vertices
  , witness_show_with_parens_case_single_edge
  , witness_minimum_monoid_identity_case_five
  , witness_minimum_monoid_identity_case_seven
  , witness_extended_zero_times_infinity_case_zero
  )
import System.Exit    (exitFailure, exitSuccess)

cases :: [(String, PropertyResult)]
cases =
  [ ("witness_de_bruijn_zero_self_loop_case_alphabet_two",
       witness_de_bruijn_zero_self_loop_case_alphabet_two)
  , ("witness_de_bruijn_zero_self_loop_case_empty_alphabet",
       witness_de_bruijn_zero_self_loop_case_empty_alphabet)
  , ("witness_show_with_parens_case_two_vertices",
       witness_show_with_parens_case_two_vertices)
  , ("witness_show_with_parens_case_single_edge",
       witness_show_with_parens_case_single_edge)
  , ("witness_minimum_monoid_identity_case_five",
       witness_minimum_monoid_identity_case_five)
  , ("witness_minimum_monoid_identity_case_seven",
       witness_minimum_monoid_identity_case_seven)
  , ("witness_extended_zero_times_infinity_case_zero",
       witness_extended_zero_times_infinity_case_zero)
  ]

main :: IO ()
main = do
  let failures =
        [ (n, msg) | (n, Fail msg) <- cases ] ++
        [ (n, "discard")       | (n, Discard) <- cases ]
  if null failures
    then do
      putStrLn $ "OK: all " ++ show (length cases) ++ " witnesses passed"
      exitSuccess
    else do
      mapM_ (\(n, m) -> putStrLn (n ++ ": FAIL: " ++ m)) failures
      exitFailure
