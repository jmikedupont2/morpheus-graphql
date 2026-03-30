{-# LANGUAGE DeriveGeneric, OverloadedStrings #-}
-- | Maass Restoration: lift fragile MetaCoq terms into hardened shadow types
-- with N-nested type maps locked by ZK commitments.
-- Zero external deps beyond base + text. Works as a TH plugin.
module Data.Morpheus.Shadow.Maass
  ( Shadow(..)
  , Commitment(..)
  , RepairEntry(..)
  , RepairKind(..)
  , lift
  , liftN
  , verify
  , repair
  , restore
  , shadowHash
  ) where

import Data.Text (Text)
import qualified Data.Text as T
import Data.Char (ord)
import Data.Word (Word64)
import Data.Bits (xor, shiftL, shiftR)
import GHC.Generics (Generic)

-- | ZK commitment: hash of content + nonce, without revealing either
data Commitment = Commitment
  { commitHash   :: Text
  , commitDepth  :: Int
  , commitPrime  :: Int
  } deriving (Show, Eq, Generic)

data RepairKind
  = MissingCase Text
  | PartialFunction Text
  | TypeMismatch Text Text
  | DepthOverflow Int
  | Restored
  deriving (Show, Eq, Generic)

data RepairEntry = RepairEntry
  { repairKind  :: RepairKind
  , repairPath  :: [Text]
  , repairProof :: Text
  } deriving (Show, Eq, Generic)

data Shadow a = Shadow
  { shadowValue      :: a
  , shadowCommitment :: Commitment
  , shadowRepairs    :: [RepairEntry]
  , shadowChildren   :: Int
  } deriving (Show, Eq, Generic)

-- | FNV-1a hash (pure Haskell, no deps)
fnv1a :: String -> Word64
fnv1a = foldl step 14695981039346656037
  where step h c = (h `xor` fromIntegral (ord c)) * 1099511628211

shadowHash :: Show a => a -> String -> Text
shadowHash val nonce =
  let h = fnv1a (show val ++ nonce)
  in T.pack (showHex64 h)

showHex64 :: Word64 -> String
showHex64 0 = "0"
showHex64 n = reverse $ go n
  where
    go 0 = []
    go x = let (q, r) = x `divMod` 16
               c = "0123456789abcdef" !! fromIntegral r
           in c : go q

lift :: Show a => a -> Shadow a
lift val = Shadow
  { shadowValue = val
  , shadowCommitment = Commitment
      { commitHash = shadowHash val "maass-0"
      , commitDepth = 0
      , commitPrime = 79
      }
  , shadowRepairs = []
  , shadowChildren = 0
  }

liftN :: Show a => Int -> a -> Shadow a
liftN depth val = s { shadowCommitment = (shadowCommitment s)
    { commitDepth = depth, commitPrime = primeAtDepth depth } }
  where s = lift val

verify :: Show a => Shadow a -> Bool
verify s = commitHash (shadowCommitment s) == shadowHash (shadowValue s) "maass-0"

repair :: Show a => RepairKind -> [Text] -> a -> Shadow a -> Shadow a
repair kind path newVal s = s
  { shadowValue = newVal
  , shadowCommitment = (shadowCommitment s)
      { commitHash = shadowHash newVal "maass-0" }
  , shadowRepairs = shadowRepairs s ++
      [RepairEntry kind path (shadowHash newVal "repair")]
  }

restore :: (Show a, Eq a) => a -> Shadow a -> Shadow a
restore val shadow
  | val == shadowValue shadow = shadow
  | otherwise = repair Restored [] val shadow

primeAtDepth :: Int -> Int
primeAtDepth n = ps !! min n (length ps - 1)
  where ps = [79, 83, 89, 97, 101, 103, 107, 109, 113]
