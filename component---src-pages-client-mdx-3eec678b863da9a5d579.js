(window.webpackJsonp=window.webpackJsonp||[]).push([[6],{"2Mcv":function(e,n,t){"use strict";t.r(n),t.d(n,"_frontmatter",(function(){return l})),t.d(n,"default",(function(){return p}));var a=t("zLVn"),r=(t("q1tI"),t("7ljp")),o=t("Bl7J"),i=(t("Wbzz"),t("vrFN")),c=["components"],l={},s={_frontmatter:l},h=o.a;function p(e){var n=e.components,t=Object(a.a)(e,c);return Object(r.b)(h,Object.assign({},s,t,{components:n,mdxType:"MDXLayout"}),Object(r.b)(i.a,{title:"Morpheus GraphQL Client",keywords:["Morpheus GraphQL Examples","GraphQL Haskell Client","Type System"],mdxType:"SEO"}),Object(r.b)("h2",null,"Morpheus GraphQL Client with Template haskell QuasiQuotes"),Object(r.b)("deckgo-highlight-code",{language:"hs",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",Object(r.b)("code",{parentName:"deckgo-highlight-code",slot:"code"},'defineByDocumentFile\n    "./schema.gql"\n  [gql|\n    query GetHero ($character: Character)\n      {\n        deity (fatherOf:$character) {\n          name\n          power\n          worships {\n            deity2Name: name\n          }\n        }\n      }\n  |]'),"\n        "),Object(r.b)("p",null,"with schema:"),Object(r.b)("deckgo-highlight-code",{language:"graphql",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",Object(r.b)("code",{parentName:"deckgo-highlight-code",slot:"code"},"input Character {\n  name: String!\n}\n\ntype Deity {\n  name: String!\n  worships: Deity\n  power: Power!\n}\n\nenum Power {\n  Lightning\n  Teleportation\n  Omniscience\n}"),"\n        "),Object(r.b)("p",null,"will validate query and Generate:"),Object(r.b)("ul",null,Object(r.b)("li",{parentName:"ul"},"namespaced response and variable types"),Object(r.b)("li",{parentName:"ul"},"instance for ",Object(r.b)("inlineCode",{parentName:"li"},"Fetch")," typeClass")),Object(r.b)("deckgo-highlight-code",{language:"haskell",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",Object(r.b)("code",{parentName:"deckgo-highlight-code",slot:"code"},"data GetHero = GetHero {\n  deity: DeityDeity\n}\n\n-- from: {user\ndata DeityDeity = DeityDeity {\n  name: Text,\n  worships: Maybe DeityWorshipsDeity\n  power: Power\n}\n\n-- from: {deity{worships\ndata DeityWorshipsDeity = DeityWorshipsDeity {\n  name: Text,\n}\n\ndata Power =\n    PowerLightning\n  | PowerTeleportation\n  | PowerOmniscience\n\ndata GetHeroArgs = GetHeroArgs {\n  character: Character\n}\n\ndata Character = Character {\n  name: Person\n}"),"\n        "),Object(r.b)("p",null,"as you see, response type field name collision can be handled with GraphQL ",Object(r.b)("inlineCode",{parentName:"p"},"alias"),"."),Object(r.b)("p",null,"with ",Object(r.b)("inlineCode",{parentName:"p"},"fetch")," you can fetch well typed response ",Object(r.b)("inlineCode",{parentName:"p"},"GetHero"),"."),Object(r.b)("deckgo-highlight-code",{language:"haskell",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",Object(r.b)("code",{parentName:"deckgo-highlight-code",slot:"code"},'  fetchHero :: Args GetHero -> m (Either String GetHero)\n  fetchHero = fetch jsonRes args\n      where\n        args = GetHeroArgs {character = Person {name = "Zeus"}}\n        jsonRes :: ByteString -> m ByteString\n        jsonRes = <GraphQL APi>'),"\n        "),Object(r.b)("p",null,"in this case, ",Object(r.b)("inlineCode",{parentName:"p"},"jsonRes")," resolves a request into a response in some monad ",Object(r.b)("inlineCode",{parentName:"p"},"m"),"."),Object(r.b)("p",null,"A ",Object(r.b)("inlineCode",{parentName:"p"},"fetch")," resolver implementation against ",Object(r.b)("a",{parentName:"p",href:"https://swapi.graph.cool"},"a real API")," may look like the following:"),Object(r.b)("deckgo-highlight-code",{language:"haskell",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",Object(r.b)("code",{parentName:"deckgo-highlight-code",slot:"code"},'{-# LANGUAGE OverloadedStrings #-}\n\nimport Data.ByteString.Lazy (ByteString)\nimport qualified Data.ByteString.Char8 as C8\nimport Network.HTTP.Req\n\nresolver :: String -> ByteString -> IO ByteString\nresolver tok b = runReq defaultHttpConfig $ do\n    let headers = header "Content-Type" "application/json"\n    responseBody <$> req POST (https "swapi.graph.cool") (ReqBodyLbs b) lbsResponse headers'),"\n        "),Object(r.b)("p",null,"this is demonstrated in examples/src/Client/StarWarsClient.hs"),Object(r.b)("p",null,"types can be generated from ",Object(r.b)("inlineCode",{parentName:"p"},"introspection")," too:"),Object(r.b)("deckgo-highlight-code",{language:"haskell",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",Object(r.b)("code",{parentName:"deckgo-highlight-code",slot:"code"},'defineByIntrospectionFile "./introspection.json"'),"\n        "))}p.isMDXComponent=!0}}]);
//# sourceMappingURL=component---src-pages-client-mdx-3eec678b863da9a5d579.js.map