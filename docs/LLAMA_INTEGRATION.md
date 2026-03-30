# Integration: MetaCoq ↔ llama.cpp via OCaml FFI

## The Link Chain

```
llama.cpp (C++)
    ↕ C FFI (ctypes / stub gen)
OCaml (lang_agent/lib/llama_cpp.ml)
    ↕ coq-of-ocaml extraction
Coq (lang_agent/lib/Llama_cpp.v) ← MetaCoq reification
    ↕ MetaCoq quote_term / unquote_term
MetaCoq Term AST
    ↕ Haskell extraction (TestMeta5/6)
th-desugar DDec/DCon/DType
    ↕ reifyAll TH plugin
GraphQL SDL (MetaCoqServer)
    ↕ HTTP/JSON
Any client (browser, curl, other LLM)
```

## Existing Pieces

### lang_agent (github:meta-introspector/lang_agent)
- `lib/llama_cpp.ml` — OCaml client to llama.cpp HTTP API
- `lib/Llama_cpp.v` — Coq types extracted via coq-of-ocaml:
  - `file_type`: ALL_F32, MOSTLY_F16, MOSTLY_Q4_0, ...
  - `vocab_type`: Spm, Bpe
  - `token_type`, `pos`, `token`, `seq_id`
- `lib/ollama.ml` / `lib/ollama_lwt.ml` — Ollama client
- `lib/lang_model.v` — Language model types in Coq
- `lib/embody.ml` / `lib/Embody.v` — Embodiment layer
- `lib/mythos.ml` / `lib/Mythos.v` — Mythology/archetype layer

### llama.cpp fork (meta-introspector/llama.cpp)
- `feature/ocaml-coq` branch — Coq grammar + OCaml integration
- `feature/metacall` branch — MetaCall plugin (Node.js in inference loop)
- `coq/helloworld.v` — Coq grammar-constrained generation
- `grammars/coq.grammar.orgiinal` — EBNF grammar for Coq output

## The Plan: Embed Everything into llama.cpp

### Phase 1: OCaml FFI stubs for llama.cpp
```
llama.cpp C API → OCaml ctypes stubs → lang_agent
```
- Generate OCaml stubs from llama.h using ctypes
- Replace HTTP client (llama_cpp.ml) with direct C FFI calls
- Link OCaml runtime into llama.cpp binary

### Phase 2: Coq verification of inference types
```
OCaml stubs → coq-of-ocaml → Coq types → MetaCoq reification
```
- Extract OCaml stubs to Coq via coq-of-ocaml
- Verify type safety of the FFI boundary in Coq
- MetaCoq reifies the verified types

### Phase 3: Haskell shadow server in the inference loop
```
MetaCoq Term → th-desugar → GraphQL → llama.cpp plugin
```
- Compile Haskell shadow server to shared library (.so)
- Load via llama.cpp plugin system (like metacall)
- Each inference step queries/updates the shadow types
- ZK commitment on each token generation step

### Phase 4: The quine
```
llama.cpp generates Coq → Coq verifies → MetaCoq reifies → 
Haskell shadows → GraphQL serves → llama.cpp consumes
```
- Grammar-constrained generation produces valid Coq
- Coq type-checks the output
- MetaCoq reifies the checked terms
- Shadow types track the verification chain
- GraphQL makes it queryable
- llama.cpp uses the query results to guide next generation

## Build: Single flake.nix

All linked via LLVM:
- llama.cpp: compiled with clang (LLVM)
- OCaml: ocamlopt uses LLVM backend (or native)
- Haskell: GHC -fllvm
- Coq: extracted to OCaml, compiled with ocamlopt

One binary. One address space. No HTTP between components.
