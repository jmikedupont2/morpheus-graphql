{-# LANGUAGE TemplateHaskell #-}
-- | TH plugin: reify types via th-desugar, shadow them, emit GraphQL
-- Zero deps beyond base + th-desugar. Works as native GHC plugin.
module ShadowPlugin (reifyAndShadow, dDecToGQL) where

import Language.Haskell.TH
import Language.Haskell.TH.Desugar
import Data.List (intercalate)

dDecToGQL :: DDec -> String
dDecToGQL (DDataD _ _ name _ _ cons _) =
  let n = nameBase name
      cnames = [nameBase cn | DCon _ _ cn _ _ <- cons]
  in case cons of
    _ | all isEnum cons -> "enum " ++ n ++ " {\n" ++ unlines ["  " ++ c | c <- cnames] ++ "}"
    [DCon _ _ _ (DRecC fields) _] ->
      "type " ++ n ++ " {\n" ++ unlines [fieldGQL f | f <- fields] ++ "}"
    _ -> "union " ++ n ++ " = " ++ intercalate " | " cnames
dDecToGQL (DTySynD name _ _) = "scalar " ++ nameBase name
dDecToGQL _ = ""

isEnum :: DCon -> Bool
isEnum (DCon _ _ _ (DNormalC _ []) _) = True
isEnum _ = False

fieldGQL :: DVarBangType -> String
fieldGQL (n, _, ty) = "  " ++ nameBase n ++ ": " ++ typeGQL ty

typeGQL :: DType -> String
typeGQL (DConT n) = case nameBase n of
  "String" -> "String"; "Text" -> "String"; "Int" -> "Int"
  "Bool" -> "Boolean"; "Float" -> "Float"; x -> x
typeGQL (DAppT (DConT n) inner)
  | nameBase n == "Maybe" = typeGQL inner
  | nameBase n == "[]"    = "[" ++ typeGQL inner ++ "]"
typeGQL (DVarT n) = nameBase n
typeGQL _ = "String"

hash :: String -> Integer
hash = foldl (\h c -> (h * 1099511628211 + fromIntegral (fromEnum c)) `mod` (2^64)) 14695981039346656037

primes :: [Int]
primes = [79,83,89,97,101,103,107,109,113]

reifyAndShadow :: Name -> Q Exp
reifyAndShadow n = do
  info <- reifyWithWarning n
  dinfo <- dsInfo info
  let (gql, depth) = case dinfo of
        DTyConI ddec _ -> (dDecToGQL ddec, length [() | DCon{} <- dcons ddec])
        _ -> ("# cannot reify " ++ nameBase n, 0)
      h = take 16 $ show (hash gql)
      p = primes !! min depth (length primes - 1)
  [| (gql, h, depth, p) |]
  where
    dcons (DDataD _ _ _ _ _ cs _) = cs
    dcons _ = []
