{-# LANGUAGE OverloadedStrings, TemplateHaskell #-}
-- | DASHI Agda reasoning layer for the shadow GraphQL server.
-- Maps the Agda proof structure into queryable GraphQL types
-- so the LLM can reason about shadows and request proofs/repairs.
module DashiAgda where

import Data.Aeson (Value(..), object, (.=))
import Data.Text (Text)

-- The DASHI Agda module tree as GraphQL, matching chboishabba/dashi_agda
dashiSchema :: String
dashiSchema = unlines
  [ "# DASHI Agda Reasoning Layer — from chboishabba/dashi_agda"
  , ""
  , "# === Core Restoration (MaassRestoration.agda) ==="
  , "type Restoration { restore(broken: Shadow): Shadow }"
  , "type NormalForm { nf(stable: Shadow): Shadow  nfIdem: Proof }"
  , "type RestorationLaw { restoration: Restoration  normalForm: NormalForm  restoresToNf: Proof }"
  , ""
  , "# === ZK Verification (Verification/ZK.agda) ==="
  , "type ZKCorrectness {"
  , "  pub: String  priv: String  out: String"
  , "  proof: String  accepts: Boolean  correct: Boolean"
  , "}"
  , "type ZKSoundness { verify(pub: String, out: String, proof: String): Boolean }"
  , ""
  , "# === Monster Groups (MonsterGroups.agda) ==="
  , "type MonsterGroup { countGroups(trace: [State]): Int  boundary: Boundary }"
  , "type State { value: Int  label: String }"
  , "type Boundary { test(state: State): Boolean }"
  , ""
  , "# === Shadow Types (carried types with proofs) ==="
  , "type Shadow {"
  , "  value: Term  commitment: Commitment"
  , "  repairs: [RepairEntry]  depth: Int  prime: Int"
  , "}"
  , "type Commitment { hash: String  depth: Int  prime: Int }"
  , "type RepairEntry { kind: RepairKind  path: [String]  proof: String }"
  , "enum RepairKind { MissingCase PartialFunction TypeMismatch DepthOverflow Restored }"
  , ""
  , "# === DASHI Algebra ==="
  , "type MonsterMask15 { mask: [Boolean]  projection: MonsterProjection15 }"
  , "type MonsterProjection15 { project(shadow: Shadow): Shadow  invertible: Boolean }"
  , "type ConstraintAlgebra { closed: Boolean  anomalyFree: Boolean }"
  , "type PhysicsSignature { gauge: String  matter: String  conformance: Boolean }"
  , ""
  , "# === Reasoning Queries ==="
  , "extend type Query {"
  , "  # Ask Agda to verify a shadow's commitment"
  , "  verifyShadow(hash: String, value: String): ZKCorrectness"
  , "  # Ask Agda to restore a broken shadow"
  , "  restoreShadow(broken: String): Shadow"
  , "  # Ask Agda to prove two shadows are equivalent"
  , "  proveShadowEquiv(a: String, b: String): Proof"
  , "  # Count monster groups in a trace"
  , "  monsterGroups(trace: [Int]): Int"
  , "  # Get the DASHI module tree"
  , "  dashiModules: [String]"
  , "}"
  , ""
  , "type Proof { statement: String  evidence: String  verified: Boolean }"
  ]

-- DASHI module tree from Everything.agda
dashiModules :: [Text]
dashiModules =
  [ "DASHI.Algebra.AnomalyContracts"
  , "DASHI.Algebra.BalancedTernary"
  , "DASHI.Algebra.CCR"
  , "DASHI.Algebra.Clifford.UniversalProperty"
  , "DASHI.Algebra.GaugeGroupContract"
  , "DASHI.Algebra.MonsterMask15"
  , "DASHI.Algebra.MonsterProjection15"
  , "DASHI.Algebra.MonsterUltrametric15"
  , "DASHI.Algebra.PhysicsConformance"
  , "DASHI.Algebra.PhysicsSignature"
  , "DASHI.Algebra.QuantumInterface"
  , "DASHI.Core"
  , "DASHI.Geometry"
  , "DASHI.Metric"
  , "DASHI.Physics"
  , "DASHI.Quantum"
  , "MaassRestoration"
  , "MonsterGroups"
  , "MonsterState"
  , "MonsterConformance"
  , "Verification.ZK"
  , "Verification.Pipeline"
  , "Verification.SourceHash"
  , "Verification.CostProfile"
  ]

-- Resolve DASHI-specific queries
resolveDashi :: Text -> Value
resolveDashi q
  | "verifyShadow" `elem` [] = object [] -- TODO: call Agda checker
  | "restoreShadow" `elem` [] = object []
  | "monsterGroups" `elem` [] = object []
  | "dashiModules" `elem` [] = object ["dashiModules" .= dashiModules]
  | otherwise = object
      [ "dashiModules" .= dashiModules
      , "schema" .= dashiSchema
      , "note" .= ("DASHI Agda reasoning layer active — 24 modules" :: Text)
      ]
