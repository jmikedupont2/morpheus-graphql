{-# LANGUAGE TemplateHaskell #-}
module Main where

import Language.Haskell.TH.Syntax (Exp, Dec, Pat, Type, Body, Lit, Con, Info)
import ShadowPlugin (reifyAndShadow)

main :: IO ()
main = do
  putStrLn "=== Maass Shadow Restoration — Native TH Plugin ==="
  putStrLn "=== GHC + th-desugar, no Python, no external deps ==="
  putStrLn ""
  let types =
        [ ("Exp",  $(reifyAndShadow ''Exp))
        , ("Dec",  $(reifyAndShadow ''Dec))
        , ("Pat",  $(reifyAndShadow ''Pat))
        , ("Type", $(reifyAndShadow ''Type))
        , ("Body", $(reifyAndShadow ''Body))
        , ("Lit",  $(reifyAndShadow ''Lit))
        , ("Con",  $(reifyAndShadow ''Con))
        , ("Info", $(reifyAndShadow ''Info))
        ]
  mapM_ (\(name, (gql, h, depth, prime)) -> do
    putStrLn $ "--- " ++ name ++ " [depth=" ++ show depth
              ++ " prime=" ++ show prime ++ " hash=" ++ h ++ "]"
    putStrLn gql
    putStrLn ""
    ) types
  putStrLn $ "Total: " ++ show (length types) ++ " shadow types generated at compile time"
