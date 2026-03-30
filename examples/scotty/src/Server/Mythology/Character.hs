{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
module Server.Mythology.Character
  ( Deity (..),
    dbDeity,
    Human (..),
    someHuman,
    dbDeityStory,
    someDeity,
    Person,
    PersonGuard,
    resolvePersons,
  )
where

import Data.Morpheus.Types (GQLType (..), TypeGuard (..))
import Data.Text (Text)
import GHC.Generics (Generic)
import Server.Mythology.Place
  ( City (..),
    Realm (..),
  )

import Server.MetaCoq.TestMeta
import Server.MetaCoq.TestMeta2
import Server.MetaCoq.TestMeta3

newtype Person = Person {name :: Text}
  deriving (Generic, GQLType)

data Deity = Deity
  { name :: Text, -- Non-Nullable Field
    power :: Maybe Text, -- Nullable Field
    realm :: Realm,
    bornAt :: Maybe City,
   storyOf :: Mutual_inductive_body
       -- Kername
       -- Ident
       -- Kername (Prod Modpath Ident)))
   -- Global_declarations -- Prod Kername Global_decl
    -- Global_declarations -> Global_env -> Maybe Global_env
  }
  deriving (Generic, GQLType)

--instance GQLType (Prod Modpath Ident) where
--  directives _ = _

data Human m = Human
  { name :: m Text,
    bornAt :: m City
--    , storyOf :: m Global_declarations
  }
  deriving (Generic, GQLType)

type PersonGuard m = TypeGuard Person (UnionPerson m)

resolvePersons :: Applicative m => [PersonGuard m]
resolvePersons = ResolveType <$> [UnionPersonDeity someDeity, UnionPersonHuman someHuman]

data UnionPerson m
  = UnionPersonDeity Deity
  | UnionPersonHuman (Human m)
  deriving (Generic, GQLType)

getTerm :: Global_declarations
getTerm = case rec_def_term of {
  (Pair (Mk_global_env a b c) d) -> b
}

someHuman :: Applicative m => Human m
someHuman = Human {
  name = pure "Odysseus",
  bornAt = pure Ithaca
  --, storyOf = pure getTerm  
  }

someDeity :: Deity
someDeity =
  Deity
    { name = "Morpheus",
      power = Just "Shapeshifting",
      realm = Dream,
--      storyOf = getTerm,
      bornAt = Nothing
    }

dbDeity :: Text -> Maybe City -> IO (Either String Deity)
dbDeity _ bornAt =
  return $
    Right $
      Deity
        { name = "Morpheus",
          power = Just "Shapeshifting",
          realm = Dream,
--          storyOf = getTerm,
          bornAt
        }
dbDeityStory :: Text -> Maybe City -> IO (Either String Global_declarations )
dbDeityStory _ storyOf =
  return $ Right $ case rec_def_term of {
    (Pair (Mk_global_env a b c) d) -> b
  --Mk_global_env T35 Global_declarations T37
  --(Prod Global_env Term)
--  (Pair a c)   -> a;
    --(Prod global_env _) -> global_env;
--    _ -> "error";
  }
