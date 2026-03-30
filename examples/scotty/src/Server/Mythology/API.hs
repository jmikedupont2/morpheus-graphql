{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StandaloneDeriving                  #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleInstances, MultiParamTypeClasses  #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies #-}

module Server.Mythology.API
  ( app,
  )
where

import Data.Morpheus.Ext.Result(GQLResult)
import Data.Morpheus.Types.Internal.AST.Fields(ArgumentsDefinition)
import Data.Morpheus.Types.Internal.AST.Stage(CONST)
import Data.Morpheus.Server.CodeGen.Internal
import Data.Morpheus.Server.Types
-- import Globals.GQLScalars (ScalarPower)

import Data.Morpheus.Types.Internal.AST.OperationType(QUERY)
import Data.Morpheus.App.Internal.Resolving.Types(ResolverValue)
import Data.Morpheus.App.Internal.Resolving.Resolver(Resolver)
import Data.Morpheus.App.Internal.Resolving.MonadResolver
import Data.Morpheus.App.Internal.Resolving.ResolveValue
import Data.Morpheus.App.Internal.Resolving.ResolverState

import Data.Morpheus.Generic( GRep,deriveTypeValue,deriveTypeDefinition )
--    GRepCons (..),
--    GRepField (..),
--    GRepFun (..),
--    GRepType (..),
--    deriveType,
--  )

import Data.Morpheus.Server.Deriving.Utils.Use
import Data.Morpheus.Server.Deriving.Utils.GScan
import Data.Morpheus.Server.Deriving.Utils.Types

-- import Data.Morpheus.Server.Deriving.Utils


import Data.Morpheus
  ( App,
    deriveApp,
  )
import Data.Morpheus.Types
  ( GQLType,
    ResolverQ,
    RootResolver (..),
    Undefined,
    defaultRootResolver,
    liftEither,
  )
import Data.Text (Text)
import Data.Morpheus.Server.Types.GQLType
import GHC.Generics (Generic,Rep)
import Server.Mythology.Character
  ( Deity,
    Human,
    PersonGuard,
    dbDeity,
    dbDeityStory,
    resolvePersons,
    someDeity,
    someHuman,
  )
import Server.Mythology.Place (City)


data Character m
  = CharacterHuman (Human m) -- Only <tyconName><conName> should generate direct link
  | CharacterDeity Deity -- Only <tyconName><conName> should generate direct link
  -- RECORDS
  | Creature {name :: Text, age :: Int}
  | BoxedDeity {boxedDeity :: Deity}
  | SomeScalarRecord {scalar :: Text}
  | --- Types
    SomeDeity Deity
  | SomeScalar Int
  | SomeMutli Int Text
  | --- ENUMS
    Zeus
  | Cronus
  deriving (Generic, GQLType)

data Query m = Query
  { deity :: DeityArgs -> m Deity,
    character :: [Character m],
    persons :: [PersonGuard m]
--    deity_story :: DeityArgs -> m Ident
  --Kername
--    deity_story :: DeityArgs -> m Global_declarations 
               
  }
  deriving (Generic, GQLType)

data DeityArgs = DeityArgs
  { name :: Text, -- Required Argument
    bornPlace :: Maybe City -- Optional Argument
  }
  deriving (Generic, GQLType)

resolveDeity :: DeityArgs -> ResolverQ e IO Deity
resolveDeity DeityArgs {name, bornPlace} =
  liftEither $ dbDeity name bornPlace

--resolveDeityStory :: DeityArgs -> ResolverQ e IO Global_declarations 
--resolveDeityStory DeityArgs {name, bornPlace}=
-- liftEither $ dbDeityStory name bornPlace

--dbDeity :: Text -> Maybe City -> IO (Either String Deity)


resolveCharacter :: Applicative m => [Character m]
resolveCharacter =
  [ CharacterHuman someHuman,
    CharacterDeity someDeity,
    Creature {name = "Lamia", age = 205},
    BoxedDeity {boxedDeity = someDeity},
    SomeScalarRecord {scalar = "Some Text"},
    ---
    SomeDeity someDeity,
    SomeScalar 12,
    SomeMutli 21 "some text",
    Zeus,
    Cronus
    -- Introspector
    --Introspector rec_def_term
  ]

rootResolver :: RootResolver IO () Query Undefined Undefined
rootResolver =
  defaultRootResolver
    { queryResolver =
        Query
          { deity = resolveDeity,
            character = resolveCharacter,
            persons = resolvePersons
--            , deity_story = resolveDeityStory
          }
    }

-- instance Data.Morpheus.Server.Deriving.Utils.GRep.GRep
--          GQLType
--          (Data.Morpheus.Server.Types.GQLType.GQLResolver
--            (Data.Morpheus.App.Internal.Resolving.Resolver.Resolver
--              Data.Morpheus.Types.Internal.AST.OperationType.QUERY
--              ()
--              IO))
--   (Data.Morpheus.App.Internal.Resolving.Resolver.Resolver
--     Data.Morpheus.Types.Internal.AST.OperationType.QUERY
--     ()
--     IO
--     (Data.Morpheus.App.Internal.Resolving.Types.ResolverValue
--       (Data.Morpheus.App.Internal.Resolving.Resolver.Resolver
--         Data.Morpheus.Types.Internal.AST.OperationType.QUERY
--         ()
--         IO)))
--          (GHC.Generics.Rep (Prod Modpath Ident))

-- instance (GRep
--                          GQLType
--                          (Data.Morpheus.Server.Types.GQLType.GQLResolver
--                             (Resolver QUERY () IO))
--                          (Resolver QUERY () IO (ResolverValue (Resolver QUERY () IO)))
--                          (GHC.Generics.Rep (Prod Modpath Ident)))

--foo ::  (Rep (Prod Modpath Ident))
--foo = _
--instance GRep GQLType 
  --  (GQLResolver (Resolver QUERY () IO))
  --  (Resolver QUERY () IO (ResolverValue (Resolver QUERY () IO)))
  --  (Rep (Prod Modpath Ident)) where
  -- deriveTypeValue  =1  -- :: GRepFun gql c Identity v -> f a -> (Bool, GRepCons v)
  -- deriveTypeDefinition  =1 -- :: GRepFun gql c Proxy v -> proxy f -> [GRepCons v]


  
app :: App () IO
app = deriveApp rootResolver



--instance GRep (GraphQLType Kername)
--   (GQLResolver QUERY)
--   (Resolver QUERY (ResolverValue QUERY))
--   Kername where
--  f = _

-- instance GRep (GraphQLType (Prod Kername Kername)) 
--                     (GQLResolver QUERY)
--                     (Resolver QUERY (ResolverValue QUERY))
--                     (Prod Kername Kername)
-- deriving via GenericGRepInstance (Prod Kername Kername)

--deriving instance GQLType (Prod Global_env Term)
--instance GQLType Global_env where
--  type KIND Global_env = TYPE

-- instance GRep (
--            GQLType
--            GQLType
--            (Data.Morpheus.Ext.Result.GQLResult
--             (Data.Morpheus.Types.Internal.AST.Fields.ArgumentsDefinition
--               Data.Morpheus.Types.Internal.AST.Stage.CONST))
--            (Rep (List (Branch Term))))
