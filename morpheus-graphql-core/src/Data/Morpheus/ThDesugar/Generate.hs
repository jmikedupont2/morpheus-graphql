{-# LANGUAGE TemplateHaskell #-}
-- | TH splice: reify Haskell types, desugar them, emit GraphQL SDL.
-- Usage:
--   $(generateSchema ''MyType)
--   $(generateSchemaFor [''Type1, ''Type2, ''Type3])
module Data.Morpheus.ThDesugar.Generate
  ( generateSchema
  , generateSchemaFor
  , reifyToGraphQL
  ) where

import Language.Haskell.TH
import Language.Haskell.TH.Desugar
import Data.Morpheus.ThDesugar.ToSchema (dDecsToSchema, dDecToGraphQL)

-- | Generate GraphQL schema string for a single type at compile time
generateSchema :: Name -> Q Exp
generateSchema name = do
  info <- reifyWithWarning name
  dinfo <- dsInfo info
  let sdl = case dinfo of
        DTyConI ddec _ -> dDecToGraphQL ddec
        _ -> "# Could not generate schema for " ++ nameBase name
  litE (stringL sdl)

-- | Generate GraphQL schema for multiple types
generateSchemaFor :: [Name] -> Q Exp
generateSchemaFor names = do
  ddecs <- mapM reifyOne names
  let sdl = dDecsToSchema ddecs
  litE (stringL sdl)
  where
    reifyOne n = do
      info <- reifyWithWarning n
      dinfo <- dsInfo info
      case dinfo of
        DTyConI ddec _ -> return ddec
        _ -> fail $ "Cannot reify " ++ nameBase n ++ " as a type declaration"

-- | Reify a type and return its GraphQL SDL as a string (runtime, in Q monad)
reifyToGraphQL :: Name -> Q String
reifyToGraphQL name = do
  info <- reifyWithWarning name
  dinfo <- dsInfo info
  return $ case dinfo of
    DTyConI ddec _ -> dDecToGraphQL ddec
    _ -> "# Could not generate schema for " ++ nameBase name
