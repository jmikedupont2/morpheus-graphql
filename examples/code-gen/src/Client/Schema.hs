{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# LANGUAGE TypeFamilies #-}

{-# HLINT ignore "Use camelCase" #-}

module Client.Schema where

import Data.Morpheus.Client.Internal.CodeGen
import Globals.GQLScalars

newtype Bird = Bird
  { name :: Maybe String
  }
  deriving (Generic, Show, Eq)

instance ToJSON Bird where
  toJSON _ = undefined -- TODO: should be real function

newtype Cat = Cat
  { name :: String
  }
  deriving (Generic, Show, Eq)

instance ToJSON Cat where
  toJSON _ = undefined -- TODO: should be real function

data CityID
  = CityIDParis
  | CityIDBLN
  | CityIDHH
  deriving (Generic, Show, Eq)

instance FromJSON CityID where
  parseJSON _ = undefined -- TODO: should be real function

instance ToJSON CityID where
  toJSON _ = undefined -- TODO: should be real function

data Coordinates = Coordinates
  { latitude :: Euro,
    longitude :: [Maybe [[UniqueID]]]
  }
  deriving (Generic, Show, Eq)

instance ToJSON Coordinates where
  toJSON _ = undefined -- TODO: should be real function

newtype Dog = Dog
  { name :: String
  }
  deriving (Generic, Show, Eq)

instance ToJSON Dog where
  toJSON _ = undefined -- TODO: should be real function

instance FromJSON Euro where
  parseJSON _ = undefined -- TODO: should be real function

instance ToJSON Euro where
  toJSON _ = undefined -- TODO: should be real function

data UniqueID = UniqueID
  { name :: Maybe String,
    id :: String,
    rec :: Maybe UniqueID
  }
  deriving (Generic, Show, Eq)

instance ToJSON UniqueID where
  toJSON _ = undefined -- TODO: should be real function
