{-# LANGUAGE TemplateHaskell #-}
module MetaCoqSchema (schema, typeEntries) where

import Language.Haskell.TH.Syntax
import ReifyGQL (reifyAll)

-- That's it. One line. Like mkBuilders! in Rust.
$(reifyAll
  [ ''Exp, ''Dec, ''Pat, ''Type, ''Body, ''Guard, ''Stmt, ''Lit
  , ''Con, ''Info, ''Range, ''Match, ''Clause, ''FunDep, ''Foreign
  , ''Fixity, ''FixityDirection, ''Safety, ''Callconv, ''Overlap
  , ''DerivStrategy, ''TyLit, ''Role, ''Pragma, ''Bang
  , ''SourceUnpackedness, ''SourceStrictness, ''RuleBndr, ''Phases
  ])
