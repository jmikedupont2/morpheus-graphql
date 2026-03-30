#!/usr/bin/env python3
"""Convert Haskell TH Syntax.hs data declarations to GraphQL SDL."""
import re, sys

TYPE_MAP = {
    'String': 'String', 'Text': 'String', 'Char': 'String',
    'Int': 'Int', 'Integer': 'Int', 'Word': 'Int', 'Word8': 'Int', 'Word64': 'Int',
    'Float': 'Float', 'Double': 'Float', 'Rational': 'Float',
    'Bool': 'Boolean', 'ByteString': 'String', 'Bytes': 'String',
    'OccName': 'String', 'PkgName': 'String', 'ModName': 'String',
    'FieldExp': 'String', 'FieldPat': 'String', 'BangType': 'String',
    'VarBangType': 'String', 'Uniq': 'Int',
}

def hs_to_gql(t):
    t = t.strip().split('--')[0].strip()
    if not t: return 'String'
    if t in TYPE_MAP: return TYPE_MAP[t]
    if t.startswith('Maybe '): return hs_to_gql(t[6:])
    if t.startswith('['): return '[' + hs_to_gql(t[1:].rstrip(']')) + ']'
    return t.split()[0]

def parse_file(path):
    with open(path) as f:
        src = f.read()
    # Remove block comments and line comments within data decls
    src = re.sub(r'\{-.*?-\}', '', src, flags=re.DOTALL)
    
    results = []
    # Find all data declarations
    # Pattern: data TypeName [tvars] = ... (until next top-level decl)
    pattern = r'^data\s+(\w+)(?:\s+\w+)*\s*$\s*=\s*(.*?)(?=^(?:data |type |class |newtype |instance |#|deriving stock|deriving instance|\w+\s*::)|\Z)'
    
    for m in re.finditer(pattern, src, re.MULTILINE | re.DOTALL):
        name = m.group(1)
        body = m.group(2).strip()
        if name in ('X',): continue  # skip internal
        
        # Remove deriving clauses at end
        body = re.sub(r'\n\s*deriving\s.*', '', body)
        
        # Split on top-level | (not inside braces/parens)
        cons = split_constructors(body)
        if not cons: continue
        
        # Classify
        is_enum = all(re.match(r'^\w+\s*$', c.strip()) for c in cons)
        
        if is_enum and len(cons) > 1:
            results.append(f'enum {name} {{')
            for c in cons:
                results.append(f'  {c.strip()}')
            results.append('}')
            results.append('')
        elif len(cons) == 1 and '{' in cons[0]:
            # Record type
            results.append(f'type {name} {{')
            fields = re.findall(r'(\w+)\s*::\s*([^,}]+)', cons[0])
            for fname, ftype in fields:
                results.append(f'  {fname}: {hs_to_gql(ftype)}')
            results.append('}')
            results.append('')
        elif len(cons) > 1:
            # Union - extract constructor names
            cnames = []
            for c in cons:
                m2 = re.match(r'\s*(\w+)', c)
                if m2: cnames.append(m2.group(1))
            if cnames:
                results.append(f'union {name} = ' + ' | '.join(cnames))
                results.append('')
                # Also emit each constructor as a type
                for c in cons:
                    m2 = re.match(r'\s*(\w+)\s*\{(.*?)\}', c, re.DOTALL)
                    if m2:
                        cname, cbody = m2.group(1), m2.group(2)
                        results.append(f'type {cname} {{')
                        fields = re.findall(r'(\w+)\s*::\s*([^,}]+)', cbody)
                        for fname, ftype in fields:
                            results.append(f'  {fname}: {hs_to_gql(ftype)}')
                        results.append('}')
                        results.append('')
        else:
            # Single constructor, no records
            m2 = re.match(r'\s*(\w+)(.*)', cons[0], re.DOTALL)
            if m2:
                cname = m2.group(1)
                args = m2.group(2).strip().split()
                if args:
                    results.append(f'type {name} {{')
                    for i, a in enumerate(args):
                        results.append(f'  field{i}: {hs_to_gql(a)}')
                    results.append('}')
                else:
                    results.append(f'type {name} {{ _: Boolean }}')
                results.append('')
    
    return '\n'.join(results)

def split_constructors(body):
    """Split on | at depth 0 (not inside {} or ())"""
    cons = []
    depth = 0
    current = ''
    for ch in body:
        if ch in '({': depth += 1
        elif ch in ')}': depth -= 1
        elif ch == '|' and depth == 0:
            cons.append(current)
            current = ''
            continue
        current += ch
    if current.strip():
        cons.append(current)
    return [c for c in cons if c.strip()]

if __name__ == '__main__':
    for path in sys.argv[1:]:
        print(parse_file(path))
