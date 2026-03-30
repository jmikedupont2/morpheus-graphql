#!/usr/bin/env python3
"""Generate the MetaCoq shadow type GraphQL schema as a DASHI eRDFa CBOR shard.
Prime 79 (next after 71=meta): the shadow domain — types of types."""
import cbor2, hashlib, json, os, sys

# The MetaCoq Term GraphQL schema — shadow of the Haskell types
SCHEMA = """# MetaCoq Shadow Type Schema — Prime 79
# Types carrying types: umbral moonshine shadow
# Each type is both data and its own schema

enum Relevance { Relevant Irrelevant }
enum CastKind { VmCast NativeCast Cast }
enum AllowedEliminations { IntoSProp IntoPropSProp IntoSetPropSProp IntoAny }
enum RecursivityKind { Finite CoFinite BiFinite }

union Name = NAnon | NNamed
type NNamed { ident: String }

type BinderAnnot { binderName: Name binderRelevance: Relevance }
type Inductive { indKername: String indNat: Int }
type Projection { projInductive: Inductive projNat1: Int projNat2: Int }
type CaseInfo { ciInductive: Inductive ciNat: Int ciRelevance: Relevance }

union Term = TRel | TVar | TSort | TConst | TInd | TConstruct
  | TProd | TLambda | TLetIn | TApp | TCast | TProj
  | TFix | TCoFix | TEvar

type TRel { relNat: Int }
type TVar { varIdent: String }
type TSort { sortLevel: String }
type TConst { constKername: String constLevels: [String] }
type TInd { indRef: Inductive indLevels: [String] }
type TConstruct { constrInd: Inductive constrIdx: Int constrLevels: [String] }
type TProd { prodAnnot: BinderAnnot prodType: Term prodBody: Term }
type TLambda { lamAnnot: BinderAnnot lamType: Term lamBody: Term }
type TLetIn { letAnnot: BinderAnnot letDef: Term letType: Term letBody: Term }
type TApp { appFn: Term appArgs: [Term] }
type TCast { castTerm: Term castKind: CastKind castType: Term }
type TProj { projRef: Projection projTerm: Term }
type TFix { fixDefs: [Def] fixIdx: Int }
type TCoFix { cofixDefs: [Def] cofixIdx: Int }
type TEvar { evarNat: Int evarTerms: [Term] }

type Def { defAnnot: BinderAnnot defType: Term defBody: Term defRargs: Int }
type ContextDecl { declAnnot: BinderAnnot declValue: Term declType: Term }
type Branch { branchNames: [BinderAnnot] branchBody: Term }
type Predicate { predLevels: [String] predTerms: [Term] predNames: [BinderAnnot] predReturn: Term }

type ConstructorBody {
  ctorName: String ctorContext: [ContextDecl]
  ctorArgs: [Term] ctorType: Term ctorArity: Int
}
type ProjectionBody { projBodyName: String projBodyRelevance: Relevance projBodyTerm: Term }

type OneInductiveBody {
  oibName: String oibContext: [ContextDecl] oibType: Term
  oibEliminations: AllowedEliminations oibConstructors: [ConstructorBody]
  oibProjections: [ProjectionBody] oibRelevance: Relevance
}
type MutualInductiveBody {
  mibRecursivity: RecursivityKind mibNparams: Int
  mibContext: [ContextDecl] mibBodies: [OneInductiveBody]
}
type ConstantBody { cbType: Term cbBody: Term cbRelevance: Relevance }
union GlobalDecl = ConstantDecl | InductiveDecl
type ConstantDecl { constantBody: ConstantBody }
type InductiveDecl { inductiveBody: MutualInductiveBody }
type GlobalDeclEntry { entryKername: String entryDecl: GlobalDecl }
type GlobalEnv { envDeclarations: [GlobalDeclEntry] }

type Query {
  term: Term
  globalEnv: GlobalEnv
  exampleNat: Term
  exampleLambda: Term
  exampleInductive: OneInductiveBody
}
"""

# Count types
types = len([l for l in SCHEMA.split('\n') if l.strip().startswith(('type ', 'enum ', 'union '))])

# Generate CID
schema_bytes = SCHEMA.encode('utf-8')
h = hashlib.sha256(schema_bytes).hexdigest()[:32]
cid = f"bafk{h}"

# Build the shard
shard = cbor2.CBORTag(55889, {
    "id": "METACOQ_SHADOW_SCHEMA_p79",
    "cid": cid,
    "domain": "shadow",
    "prime": 79,
    "functions": types,
    "total_risk": 0,
    "tags": ["metacoq", "shadow-type", "graphql", "umbral-moonshine", "carried-types", "dashi", "erdfa"],
    "component": {
        "type": "Schema",
        "format": "graphql-sdl",
        "version": "metacoq-v1.3.2",
        "ghc_compat": ["9.2", "9.4", "9.6", "9.8", "9.10", "9.12", "9.14"],
        "th_desugar": "meta-introspector/th-desugar@rename",
        "morpheus_graphql": "jmikedupont2/morpheus-graphql@introspector-v0.28.5",
    },
    "table": {
        "headers": ["category", "count", "description"],
        "rows": [
            ["enums", str(len([l for l in SCHEMA.split('\n') if l.strip().startswith('enum ')])), "Finite types"],
            ["unions", str(len([l for l in SCHEMA.split('\n') if l.strip().startswith('union ')])), "Sum types (carried)"],
            ["objects", str(len([l for l in SCHEMA.split('\n') if l.strip().startswith('type ')])), "Product types (carriers)"],
            ["recursive", "6", "Self-referential (Term, Def, Branch, Predicate, ContextDecl, OneInductiveBody)"],
        ]
    },
    "content": SCHEMA,
})

# Write shard
outdir = os.path.expanduser("~/.zkperf/docs-shards")
outpath = os.path.join(outdir, "METACOQ_SHADOW_SCHEMA_p79.cbor")
with open(outpath, 'wb') as f:
    cbor2.dump(shard, f)

# Also write the schema file
schema_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "docs", "ghc-schemas")
os.makedirs(schema_dir, exist_ok=True)
schema_path = os.path.join(schema_dir, "metacoq-shadow.graphql")
with open(schema_path, 'w') as f:
    f.write(SCHEMA)

print(f"Shadow schema: {types} types")
print(f"CID: {cid}")
print(f"Shard: {outpath}")
print(f"Schema: {schema_path}")
print(f"Prime: 79 (shadow domain)")
