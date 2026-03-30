{-# LANGUAGE DeriveGeneric, DeriveAnyClass, OverloadedStrings, TypeFamilies #-}
-- | MetaCoq Term types as a morpheus-graphql server
-- Carried types: types that carry types (umbral moonshine)
module Main where

import Data.Morpheus (interpreter)
import Data.Morpheus.Types
import GHC.Generics (Generic)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Lazy as LT
import Web.Scotty (scotty, post, body, raw)
import Data.ByteString.Lazy (ByteString)

-- === MetaCoq Core Types (extracted from Coq) ===

data Relevance = Relevant | Irrelevant
  deriving (Generic, GQLType, Show)

data Name = NAnon | NNamed { ident :: Text }
  deriving (Generic, GQLType, Show)

data BinderAnnot = BinderAnnot
  { binderName :: Name
  , binderRelevance :: Relevance
  } deriving (Generic, GQLType, Show)

data CastKind = VmCast | NativeCast | Cast
  deriving (Generic, GQLType, Show)

data Nat = O | S { pred :: Nat }
  deriving (Generic, GQLType, Show)

data Inductive = MkInd
  { indKername :: Text
  , indNat :: Int
  } deriving (Generic, GQLType, Show)

data Projection = MkProjection
  { projInductive :: Inductive
  , projNat1 :: Int
  , projNat2 :: Int
  } deriving (Generic, GQLType, Show)

data CaseInfo = CaseInfo
  { ciInductive :: Inductive
  , ciNat :: Int
  , ciRelevance :: Relevance
  } deriving (Generic, GQLType, Show)

data AllowedEliminations = IntoSProp | IntoPropSProp | IntoSetPropSProp | IntoAny
  deriving (Generic, GQLType, Show)

data RecursivityKind = Finite | CoFinite | BiFinite
  deriving (Generic, GQLType, Show)

-- === The Core: Term (types carrying types) ===

data Term
  = TRel { relNat :: Int }
  | TVar { varIdent :: Text }
  | TSort { sortLevel :: Text }
  | TConst { constKername :: Text, constLevels :: [Text] }
  | TInd { indRef :: Inductive, indLevels :: [Text] }
  | TConstruct { constrInd :: Inductive, constrIdx :: Int, constrLevels :: [Text] }
  | TProd { prodAnnot :: BinderAnnot, prodType :: Term, prodBody :: Term }
  | TLambda { lamAnnot :: BinderAnnot, lamType :: Term, lamBody :: Term }
  | TLetIn { letAnnot :: BinderAnnot, letDef :: Term, letType :: Term, letBody :: Term }
  | TApp { appFn :: Term, appArgs :: [Term] }
  | TCast { castTerm :: Term, castKind :: CastKind, castType :: Term }
  | TProj { projRef :: Projection, projTerm :: Term }
  | TFix { fixDefs :: [Def], fixIdx :: Int }
  | TCoFix { cofixDefs :: [Def], cofixIdx :: Int }
  | TEvar { evarNat :: Int, evarTerms :: [Term] }
  deriving (Generic, GQLType, Show)

data Def = Def
  { defAnnot :: BinderAnnot
  , defType :: Term
  , defBody :: Term
  , defRargs :: Int
  } deriving (Generic, GQLType, Show)

data ContextDecl = ContextDecl
  { declAnnot :: BinderAnnot
  , declValue :: Maybe Term
  , declType :: Term
  } deriving (Generic, GQLType, Show)

data Branch = Branch
  { branchNames :: [BinderAnnot]
  , branchBody :: Term
  } deriving (Generic, GQLType, Show)

data Predicate = Predicate
  { predLevels :: [Text]
  , predTerms :: [Term]
  , predNames :: [BinderAnnot]
  , predReturn :: Term
  } deriving (Generic, GQLType, Show)

-- === Inductive Bodies (the carried types) ===

data ConstructorBody = ConstructorBody
  { ctorName :: Text
  , ctorContext :: [ContextDecl]
  , ctorArgs :: [Term]
  , ctorType :: Term
  , ctorArity :: Int
  } deriving (Generic, GQLType, Show)

data ProjectionBody = ProjectionBody
  { projBodyName :: Text
  , projBodyRelevance :: Relevance
  , projBodyTerm :: Term
  } deriving (Generic, GQLType, Show)

data OneInductiveBody = OneInductiveBody
  { oibName :: Text
  , oibContext :: [ContextDecl]
  , oibType :: Term
  , oibEliminations :: AllowedEliminations
  , oibConstructors :: [ConstructorBody]
  , oibProjections :: [ProjectionBody]
  , oibRelevance :: Relevance
  } deriving (Generic, GQLType, Show)

data MutualInductiveBody = MutualInductiveBody
  { mibRecursivity :: RecursivityKind
  , mibNparams :: Int
  , mibContext :: [ContextDecl]
  , mibBodies :: [OneInductiveBody]
  } deriving (Generic, GQLType, Show)

data ConstantBody = ConstantBody
  { cbType :: Term
  , cbBody :: Maybe Term
  , cbRelevance :: Relevance
  } deriving (Generic, GQLType, Show)

data GlobalDecl
  = ConstantDecl { constantBody :: ConstantBody }
  | InductiveDecl { inductiveBody :: MutualInductiveBody }
  deriving (Generic, GQLType, Show)

data GlobalEnv = GlobalEnv
  { envDeclarations :: [GlobalDeclEntry]
  } deriving (Generic, GQLType, Show)

data GlobalDeclEntry = GlobalDeclEntry
  { entryKername :: Text
  , entryDecl :: GlobalDecl
  } deriving (Generic, GQLType, Show)

-- === GraphQL API ===

data Query m = Query
  { term :: m Term
  , globalEnv :: m GlobalEnv
  , exampleNat :: m Term
  , exampleLambda :: m Term
  , exampleInductive :: m OneInductiveBody
  } deriving (Generic, GQLType)

-- Default examples: the identity function λ(x:Nat).x
mkAnnot :: Text -> BinderAnnot
mkAnnot n = BinderAnnot (NNamed n) Relevant

exNat :: Term
exNat = TInd (MkInd "Coq.Init.Datatypes.nat" 0) []

exLambda :: Term
exLambda = TLambda (mkAnnot "x") exNat (TRel 0)

exInductive :: OneInductiveBody
exInductive = OneInductiveBody
  { oibName = "nat"
  , oibContext = []
  , oibType = TSort "Set"
  , oibEliminations = IntoAny
  , oibConstructors =
      [ ConstructorBody "O" [] [] exNat 0
      , ConstructorBody "S" [] [exNat] (TProd (mkAnnot "_") exNat exNat) 1
      ]
  , oibProjections = []
  , oibRelevance = Relevant
  }

rootResolver :: RootResolver IO () Query Undefined Undefined
rootResolver = defaultRootResolver
  { queryResolver = Query
      { term = pure exLambda
      , globalEnv = pure $ GlobalEnv []
      , exampleNat = pure exNat
      , exampleLambda = pure exLambda
      , exampleInductive = pure exInductive
      }
  }

app :: ByteString -> IO ByteString
app = interpreter rootResolver

main :: IO ()
main = do
  putStrLn "MetaCoq GraphQL server on http://localhost:3000"
  putStrLn "Try: { exampleInductive { oibName oibConstructors { ctorName ctorArity } } }"
  scotty 3000 $ post "/api" $ raw =<< (liftIO . app =<< body)
