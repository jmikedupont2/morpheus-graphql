{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}
-- | Example: define Haskell types, generate GraphQL schema from them
module Example where

import Data.Morpheus.ThDesugar.Generate (generateSchema, generateSchemaFor)
import GHC.Generics (Generic)

-- Define your Haskell types normally
data Deity = Deity
  { deityName :: String
  , deityPower :: Maybe String
  , deityRealm :: Realm
  } deriving (Generic)

data Realm = Olympus | Underworld | Sea
  deriving (Generic)

data Human = Human
  { humanName :: String
  , humanAge :: Int
  , humanPatron :: Maybe Deity
  } deriving (Generic)

-- Generate GraphQL at compile time:
--
-- deitySchema :: String
-- deitySchema = $(generateSchema ''Deity)
--
-- fullSchema :: String
-- fullSchema = $(generateSchemaFor [''Deity, ''Realm, ''Human])
--
-- This produces:
--
--   type Deity {
--     deityName: String
--     deityPower: String
--     deityRealm: Realm
--   }
--
--   enum Realm {
--     Olympus
--     Underworld
--     Sea
--   }
--
--   type Human {
--     humanName: String
--     humanAge: Int
--     humanPatron: Deity
--   }
