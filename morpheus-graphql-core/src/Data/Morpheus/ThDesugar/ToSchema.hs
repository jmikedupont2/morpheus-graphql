{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
-- | Convert th-desugar AST (DDec, DCon, DType) to GraphQL SDL schema text.
-- This is the "Haskell to GraphQL" direction.
module Data.Morpheus.ThDesugar.ToSchema
  ( dDecToGraphQL
  , dDecsToSchema
  , dTypeToGraphQLType
  ) where

import Data.List (intercalate)
import Language.Haskell.TH (Name, nameBase)
import Language.Haskell.TH.Desugar.AST

-- | Convert a list of DDecs to a full GraphQL schema string
dDecsToSchema :: [DDec] -> String
dDecsToSchema = unlines . concatMap dDecToLines

-- | Convert a single DDec to GraphQL SDL lines
dDecToGraphQL :: DDec -> String
dDecToGraphQL = unlines . dDecToLines

dDecToLines :: DDec -> [String]
-- Data type with record constructors -> GraphQL type
dDecToLines (DDataD _ _ name _tvbs _mkind cons _derivs) =
  case cons of
    -- Single constructor with records -> Object type
    [DCon _ _ _cname (DRecC fields) _rty] ->
      [ "type " ++ nameBase name ++ " {"
      ] ++ map fieldToGraphQL fields ++
      [ "}" , "" ]
    -- Multiple constructors, no fields -> Enum
    _ | all isEnumCon cons ->
      [ "enum " ++ nameBase name ++ " {"
      ] ++ map conToEnum cons ++
      [ "}" , "" ]
    -- Multiple constructors with fields -> Union
    _ ->
      [ "union " ++ nameBase name ++ " = "
        ++ intercalate " | " (map conName cons)
      , "" ]
-- Type synonym -> scalar alias (comment)
dDecToLines (DTySynD name _tvbs _ty) =
  [ "# type alias: " ++ nameBase name
  , "scalar " ++ nameBase name
  , "" ]
-- Class -> interface
dDecToLines (DClassD _cxt name _tvbs _fundeps _decs) =
  [ "interface " ++ nameBase name ++ " {"
  , "  # methods from typeclass"
  ] ++ concatMap classMethodToField _decs ++
  [ "}" , "" ]
dDecToLines _ = []

-- | Convert a record field to GraphQL field
fieldToGraphQL :: DVarBangType -> String
fieldToGraphQL (n, _bang, ty) =
  "  " ++ nameBase n ++ ": " ++ dTypeToGraphQLType ty

-- | Convert a DType to a GraphQL type reference
dTypeToGraphQLType :: DType -> String
dTypeToGraphQLType (DConT n)
  | nameBase n == "String"  = "String"
  | nameBase n == "Text"    = "String"
  | nameBase n == "Int"     = "Int"
  | nameBase n == "Integer" = "Int"
  | nameBase n == "Float"   = "Float"
  | nameBase n == "Double"  = "Float"
  | nameBase n == "Bool"    = "Boolean"
  | nameBase n == "ID"      = "ID"
  | otherwise               = nameBase n
dTypeToGraphQLType (DAppT (DConT n) inner)
  | nameBase n == "Maybe"   = dTypeToGraphQLType inner
  | nameBase n == "[]"      = "[" ++ dTypeToGraphQLType inner ++ "]"
  | nameBase n == "List"    = "[" ++ dTypeToGraphQLType inner ++ "]"
  | nameBase n == "NonEmpty" = "[" ++ dTypeToGraphQLType inner ++ "!]"
  | nameBase n == "IO"      = dTypeToGraphQLType inner
  | nameBase n == "m"       = dTypeToGraphQLType inner
  | otherwise               = nameBase n
-- List syntax [a]
dTypeToGraphQLType (DAppT DArrowT _) = "String # (function type)"
dTypeToGraphQLType (DVarT n) = nameBase n
dTypeToGraphQLType (DSigT t _) = dTypeToGraphQLType t
dTypeToGraphQLType _ = "String # (unknown type)"

-- Helpers
isEnumCon :: DCon -> Bool
isEnumCon (DCon _ _ _ (DNormalC _ []) _) = True
isEnumCon _ = False

conToEnum :: DCon -> String
conToEnum (DCon _ _ n _ _) = "  " ++ nameBase n

conName :: DCon -> String
conName (DCon _ _ n _ _) = nameBase n

classMethodToField :: DDec -> [String]
classMethodToField (DLetDec (DSigD n ty)) =
  ["  " ++ nameBase n ++ ": " ++ dTypeToGraphQLType ty]
classMethodToField _ = []
