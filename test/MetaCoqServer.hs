{-# LANGUAGE OverloadedStrings, TemplateHaskell #-}
-- | MetaCoq GraphQL server — serves TH shadow types directly
-- Deps: scotty + aeson + th-desugar. No morpheus needed.
-- Build: ghc -XTemplateHaskell MetaCoqSchema.hs MetaCoqServer.hs -o metacoq-server
module Main where

import MetaCoqSchema (schema, typeEntries)
import DashiAgda (dashiSchema, dashiModules, resolveDashi)
import Web.Scotty
import Data.Aeson (object, (.=), Value(..), encode, decode)
import qualified Data.Aeson.KeyMap as KM
import qualified Data.Aeson.Key as K
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Lazy as LT
import qualified Data.ByteString.Lazy as BL
import Data.Maybe (fromMaybe)

main :: IO ()
main = do
  putStrLn "=== MetaCoq Shadow GraphQL Server ==="
  putStrLn $ show (length typeEntries) ++ " types compiled from GHC TH"
  putStrLn "http://localhost:3000/graphql"
  putStrLn ""
  putStrLn "Try:"
  putStrLn "  curl -X POST localhost:3000/graphql -H 'Content-Type: application/json' \\"
  putStrLn "    -d '{\"query\": \"{ schema }\"}'"
  putStrLn ""
  scotty 3000 $ do
    -- GraphQL endpoint
    post "/graphql" $ do
      bod <- body
      let req = fromMaybe (object []) (decode bod :: Maybe Value)
          query = extractQuery req
          result = resolveQuery query
      json $ object ["data" .= result]

    -- Schema introspection (combined: TH + DASHI)
    get "/schema" $ do
      text (LT.pack (schema ++ "\n" ++ dashiSchema))

    -- DASHI modules
    get "/dashi" $ do
      json $ object ["modules" .= dashiModules, "count" .= length dashiModules]

    -- Health
    get "/" $ do
      json $ object
        [ "service" .= ("metacoq-shadow-graphql" :: Text)
        , "types" .= length typeEntries
        , "endpoints" .= (["/graphql", "/schema", "/types", "/dashi"] :: [Text])
        ]

    -- Type list
    get "/types" $ do
      json $ object
        [ "types" .= [object ["name" .= n, "schema" .= s] | (n, s) <- typeEntries]
        ]

extractQuery :: Value -> Text
extractQuery (Object o) = case KM.lookup (K.fromString "query") o of
  Just (String q) -> q
  _ -> ""
extractQuery _ = ""

-- Minimal GraphQL resolver — handles schema, types, term queries
resolveQuery :: Text -> Value
resolveQuery q
  | "schema" `T.isInfixOf` q = object ["schema" .= schema]
  | "types" `T.isInfixOf` q = object ["types" .= [n | (n, _) <- typeEntries]]
  | "term" `T.isInfixOf` q = object ["term" .= exampleTerm]
  | "dashiModules" `T.isInfixOf` q = object ["dashiModules" .= dashiModules]
  | "verifyShadow" `T.isInfixOf` q = object ["verifyShadow" .= object
      ["pub" .= ("" :: Text), "verified" .= True, "note" .= ("DASHI ZK stub — connect to Agda checker" :: Text)]]
  | "restoreShadow" `T.isInfixOf` q = object ["restoreShadow" .= object
      ["value" .= exampleTerm, "depth" .= (0 :: Int), "prime" .= (79 :: Int), "repairs" .= ([] :: [Text])]]
  | "__schema" `T.isInfixOf` q = introspection
  | otherwise = object ["error" .= ("unknown query" :: Text)]

exampleTerm :: Value
exampleTerm = object
  [ "tag" .= ("TLambda" :: Text)
  , "annot" .= object ["name" .= ("x" :: Text), "relevance" .= ("Relevant" :: Text)]
  , "type" .= object ["tag" .= ("TInd" :: Text), "kername" .= ("Coq.Init.Datatypes.nat" :: Text)]
  , "body" .= object ["tag" .= ("TRel" :: Text), "index" .= (0 :: Int)]
  ]

introspection :: Value
introspection = object
  [ "queryType" .= object ["name" .= ("Query" :: Text)]
  , "types" .= [object ["name" .= n, "kind" .= ("UNION" :: Text)] | (n, _) <- typeEntries]
  ]
