{-# LANGUAGE TemplateHaskell #-}
module ReifyGQL (reifyGQL, reifyAll) where

import Language.Haskell.TH
import Language.Haskell.TH.Desugar
import Data.List (intercalate)

dDecToGQL :: DDec -> String
dDecToGQL (DDataD _ _ name _ _ cons _) =
  let n = nameBase name; cnames = [nameBase cn | DCon _ _ cn _ _ <- cons]
  in if all (\(DCon _ _ _ fs _) -> case fs of DNormalC _ [] -> True; _ -> False) cons
     then "enum " ++ n ++ " { " ++ unwords cnames ++ " }"
     else "union " ++ n ++ " = " ++ intercalate " | " cnames
dDecToGQL (DTySynD name _ _) = "scalar " ++ nameBase name
dDecToGQL _ = ""

reifyGQL :: Name -> Q Exp
reifyGQL n = do
  info <- reifyWithWarning n
  dinfo <- dsInfo info
  let gql = case dinfo of { DTyConI d _ -> dDecToGQL d; _ -> "" }
  litE (stringL gql)

-- | The mkBuilders! equivalent: give it a list of Names, get back
-- schema :: String and typeEntries :: [(String, String)]
reifyAll :: [Name] -> Q [Dec]
reifyAll names = do
  entries <- mapM reifyOne names
  let schemaStr = unlines $ "# MetaCoq Shadow Schema — auto-generated" : map snd entries
      entriesExp = listE [tupE [litE (stringL n), litE (stringL g)] | (n, g) <- entries]
  sequence
    [ valD (varP (mkName "schema")) (normalB (litE (stringL schemaStr))) []
    , valD (varP (mkName "typeEntries")) (normalB entriesExp) []
    ]
  where
    reifyOne n = do
      info <- reifyWithWarning n
      dinfo <- dsInfo info
      let gql = case dinfo of { DTyConI d _ -> dDecToGQL d; _ -> "" }
      pure (nameBase n, gql)
