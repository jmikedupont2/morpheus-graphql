"use strict";(self.webpackChunkmorpheus_graphql_docs=self.webpackChunkmorpheus_graphql_docs||[]).push([[397],{307:function(e,n,t){t.d(n,{$:function(){return o}});var i=t(7294),r=t(1280),a={color:"black",textDecoration:"none",padding:"0.1rem 0rem"},o=function(e){var n=e.id,t=e.children,o=e.level,l=void 0===o?1:o;return(0,(0,i.useContext)(r.L)[1])({id:n,level:l,children:t}),1===l?i.createElement("h2",{id:""+n,style:a},t):i.createElement("h3",{id:""+n,style:a},t)};n.Z=o},4165:function(e,n,t){t.r(n),t.d(n,{_frontmatter:function(){return s},default:function(){return u}});var i=t(1531),r=(t(7294),t(4983)),a=t(9882),o=t(9357),l=t(307),d=["components"],s={},p={_frontmatter:s},c=a.Z;function u(e){var n=e.components,t=(0,i.Z)(e,d);return(0,r.kt)(c,Object.assign({},p,t,{components:n,mdxType:"MDXLayout"}),(0,r.kt)(o.Z,{title:"Type System",keywords:["Morpheus GraphQL","GraphQL","Haskell","Type System"],mdxType:"SEO"}),(0,r.kt)("h1",null,"Server"),(0,r.kt)(l.$,{id:"type-system",mdxType:"Section"},"Type System"),(0,r.kt)("p",null,"Morpheus GraphQL covers all GraphQL data types with an equivalent\nHaskell representation. A prerequisite for these representation types is that\nthey must be derived by ",(0,r.kt)("inlineCode",{parentName:"p"},"Generic")," and provide corresponding ",(0,r.kt)("inlineCode",{parentName:"p"},"GQLType")," instances."),(0,r.kt)(l.$,{id:"objects",level:2,mdxType:"Section"},"Object types"),(0,r.kt)("p",null,"Object types are represented in Morpheus with Haskell records,\nwhere the parameter ",(0,r.kt)("inlineCode",{parentName:"p"},"m")," passes the resolution monad\nto the field resolution functions. The following code snippet, for example,\ndefines the type Deity with a nullable field ",(0,r.kt)("inlineCode",{parentName:"p"},"power")," and a non-nullable field ",(0,r.kt)("inlineCode",{parentName:"p"},"name"),"."),(0,r.kt)("deckgo-highlight-code",{language:"haskell",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",(0,r.kt)("code",{parentName:"deckgo-highlight-code",slot:"code"},"data Deity m = Deity\n  { name :: m Text         -- Non-Nullable Field\n  , power :: m Maybe Text   -- Nullable Field\n  } deriving\n    ( Generic\n    , GQLType\n    )"),"\n        "),(0,r.kt)(l.$,{id:"arguments",level:3,mdxType:"Section"},"Arguments"),(0,r.kt)("p",null,"GraphQL arguments can be represented with two ways:"),(0,r.kt)("h4",null,"Haskell records"),(0,r.kt)("p",null,"we can use Haskell records to declare GraphQL arguments,\nwhere each field of a record represents a particular\nargument, and can be accessed by name."),(0,r.kt)("deckgo-highlight-code",{language:"haskell",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",(0,r.kt)("code",{parentName:"deckgo-highlight-code",slot:"code"},"data Query m = Query\n  { deity :: DeityArgs -> m Deity\n  } deriving\n    ( Generic\n    , GQLType\n    )\n\ndata DeityArgs = DeityArgs\n  { name      :: Text        -- Required Argument\n  , mythology :: Maybe Text  -- Optional Argument\n  } deriving\n     ( Generic,\n       GQLType\n     )"),"\n        "),(0,r.kt)("p",null,'This approach is quite convenient for representing multiple arguments,\nbut cumbersome if we only need one argument for each field.\nThat is why we also introduce "Tagged Arguments".'),(0,r.kt)("h4",null,"Tagged function arguments"),(0,r.kt)("p",null,"Tagged arguments leverage type-level literals and enable GraphQL\narguments to be represented as a chain of named function arguments.\ne.g. the following type defines GraphQL field ",(0,r.kt)("inlineCode",{parentName:"p"},"deity")," with the\noptional argument ",(0,r.kt)("inlineCode",{parentName:"p"},"name")," of type ",(0,r.kt)("inlineCode",{parentName:"p"},"String"),"."),(0,r.kt)("deckgo-highlight-code",{language:"haskell",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",(0,r.kt)("code",{parentName:"deckgo-highlight-code",slot:"code"},'data Query m = Query\n  { deity :: Arg "name" (Maybe Text) -> m Deity\n  } deriving\n    ( Generic\n    , GQLType\n    )'),"\n        "),(0,r.kt)(l.$,{id:"query",level:3,mdxType:"Section"},"Query"),(0,r.kt)("p",null,"the GraphQL query type is represented in Morpheus GraphQL as a regular object type named ",(0,r.kt)("inlineCode",{parentName:"p"},"Query"),"."),(0,r.kt)("deckgo-highlight-code",{language:"haskell",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",(0,r.kt)("code",{parentName:"deckgo-highlight-code",slot:"code"},"data Query m = Query\n  { deity ::  m Deity\n  } deriving\n    ( Generic\n    , GQLType\n    )"),"\n        "),(0,r.kt)(l.$,{id:"mutations",level:3,mdxType:"Section"},"Mutations"),(0,r.kt)("p",null,"In addition to queries, Morpheus also supports mutations. They behave just like regular queries and are defined similarly:"),(0,r.kt)("deckgo-highlight-code",{language:"haskell",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",(0,r.kt)("code",{parentName:"deckgo-highlight-code",slot:"code"},"newtype Mutation m = Mutation\n  { createDeity :: MutArgs -> m Deity\n  } deriving (Generic, GQLType)\n\nrootResolver :: RootResolver IO  () Query Mutation Undefined\nrootResolver =\n  RootResolver\n    { queryResolver = Query {...}\n    , mutationResolver = Mutation { createDeity }\n    , subscriptionResolver = Undefined\n    }\n    where\n      -- Mutation Without Event Triggering\n      createDeity :: MutArgs -> ResolverM () IO Deity\n      createDeity_args = lift setDBAddress\n\ngqlApi :: ByteString -> IO ByteString\ngqlApi = interpreter rootResolver"),"\n        "),(0,r.kt)(l.$,{id:"subscription",level:3,mdxType:"Section"},"Subscriptions"),(0,r.kt)("p",null,"In morpheus subscription and mutation communicate with Events,\n",(0,r.kt)("inlineCode",{parentName:"p"},"Event")," consists with user defined ",(0,r.kt)("inlineCode",{parentName:"p"},"Channel")," and ",(0,r.kt)("inlineCode",{parentName:"p"},"Content"),"."),(0,r.kt)("p",null,"Every subscription has its own Channel by which it will be triggered"),(0,r.kt)("deckgo-highlight-code",{language:"haskell",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",(0,r.kt)("code",{parentName:"deckgo-highlight-code",slot:"code"},"data Channel\n  = ChannelA\n  | ChannelB\n\ndata Content\n  = ContentA Int\n  | ContentB Text\n\ntype MyEvent = Event Channel Content\n\nnewtype Query m = Query\n  { deity :: m Deity\n  } deriving (Generic)\n\nnewtype Mutation m = Mutation\n  { createDeity :: m Deity\n  } deriving (Generic)\n\nnewtype Subscription (m ::  * -> * ) = Subscription\n  { newDeity :: m  Deity\n  } deriving (Generic)\n\nnewtype Subscription (m :: * -> *) = Subscription\n{ newDeity :: SubscriptionField (m Deity),\n}\nderiving (Generic)\n\n\ntype APIEvent = Event Channel Content\n\nrootResolver :: RootResolver IO APIEvent Query Mutation Subscription\nrootResolver = RootResolver\n  { queryResolver        = Query { deity = fetchDeity }\n  , mutationResolver     = Mutation { createDeity }\n  , subscriptionResolver = Subscription { newDeity }\n  }\n where\n  -- Mutation Without Event Triggering\n  createDeity :: ResolverM EVENT IO Address\n  createDeity = do\n      requireAuthorized\n      publish [Event { channels = [ChannelA], content = ContentA 1 }]\n      lift dbCreateDeity\n  newDeity :: SubscriptionField (ResolverS EVENT IO Deity)\n  newDeity = subscribe ChannelA $ do\n    -- executed only once\n    -- immediate response on failures\n    requireAuthorized\n    pure $ \\(Event _ content) -> do\n        -- executes on every event\n        lift (getDBAddress content)"),"\n        "),(0,r.kt)(l.$,{id:"scalars",level:2,mdxType:"Section"},"Scalar types"),(0,r.kt)("p",null,"any Haskell data type can be represented as a GraphQL scalar type.\nIn order to do this, the type must be associated as\n",(0,r.kt)("inlineCode",{parentName:"p"},"SCALAR")," and implemented with ",(0,r.kt)("inlineCode",{parentName:"p"},"DecodeScalar")," and ",(0,r.kt)("inlineCode",{parentName:"p"},"EncodeScalar")," instances."),(0,r.kt)("deckgo-highlight-code",{language:"haskell",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",(0,r.kt)("code",{parentName:"deckgo-highlight-code",slot:"code"},'data Odd = Odd Int  deriving (Generic)\n\ninstance DecodeScalar Euro where\n  decodeScalar (Int x) = pure $ Odd (... )\n  decodeScalar _ = Left "invalid Value!"\n\ninstance EncodeScalar Euro where\n  encodeScalar (Odd value) = Int value\n\ninstance GQLType Odd where\n  type KIND Odd = SCALAR'),"\n        "),(0,r.kt)(l.$,{id:"enums",level:2,mdxType:"Section"},"Enumeration types"),(0,r.kt)("p",null,"Data types where all constructors are empty are derived as GraphQL enums."),(0,r.kt)("deckgo-highlight-code",{language:"haskell",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",(0,r.kt)("code",{parentName:"deckgo-highlight-code",slot:"code"},"data City\n  = Athens\n  | Sparta\n  | Corinth\n  | Delphi\n  | Argos\n  deriving\n    ( Generic\n    , GQLType\n    )"),"\n        "),(0,r.kt)(l.$,{id:"wrappers",level:2,mdxType:"Section"},"Lists and Non-Null"),(0,r.kt)("p",null,"GraphQL Lists are represented with Haskell Lists.\nHowever, since in Haskell each type is intrinsically not nullable,\nnullable GraphQL fields are represented with ",(0,r.kt)("inlineCode",{parentName:"p"},"Maybe")," Haskell data type and non-nullable\nGraphQL fields with regular Haskell datatypes."),(0,r.kt)(l.$,{id:"interfaces",level:2,mdxType:"Section"},"Interfaces"),(0,r.kt)("h6",null,"Note: this feature will be introduced in version ",(0,r.kt)("strong",{parentName:"h6"},"0.18.0")),(0,r.kt)("p",null,"GraphQL interfaces is represented in Morpheus with ",(0,r.kt)("inlineCode",{parentName:"p"},"TypeGuard"),".\nin the following data type definition every use of ",(0,r.kt)("inlineCode",{parentName:"p"},"PersonInterface"),"\nwill be represented as GraphQL interface ",(0,r.kt)("inlineCode",{parentName:"p"},"Person")," and allow server to\nresolve different types from union ",(0,r.kt)("inlineCode",{parentName:"p"},"PersonImplements"),"."),(0,r.kt)("p",null,"All types of the union ",(0,r.kt)("inlineCode",{parentName:"p"},"PersonImplements")," must be objects\nand contain fields of type ",(0,r.kt)("inlineCode",{parentName:"p"},"Person"),", otherwise the derivation fails."),(0,r.kt)("deckgo-highlight-code",{language:"haskell",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",(0,r.kt)("code",{parentName:"deckgo-highlight-code",slot:"code"},"  -- interface Person\ndata Person m = Person { name ::  m Text }\n  deriving\n    (\n      Generic,\n      GQLType\n    )\n\ndata PersonImplements m\n  = PersonImplementsUser (User m)\n  | PersonImplementsDeity (Deity m)\n  deriving\n    (\n      Generic,\n      GQLType\n    )\n\n-- typeGuard guards all variabts of union with person fields\ntype PersonInterface m = TypeGuard Person (PersonImplements m)"),"\n        "),(0,r.kt)(l.$,{id:"unions",level:2,mdxType:"Section"},"Unions"),(0,r.kt)("p",null,"To use union type, all you have to do is derive the ",(0,r.kt)("inlineCode",{parentName:"p"},"GQLType")," class. Using GraphQL ",(0,r.kt)("a",{parentName:"p",href:"https://graphql.org/learn/queries/#fragments"},(0,r.kt)("em",{parentName:"a"},"fragments")),", the arguments of each data constructor can be accessed from the GraphQL client."),(0,r.kt)("deckgo-highlight-code",{language:"haskell",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",(0,r.kt)("code",{parentName:"deckgo-highlight-code",slot:"code"},"data Character\n  = CharacterDeity Deity -- will be unwrapped, since Character + Deity = CharacterDeity\n  | SomeDeity Deity -- will be wrapped since Character + Deity != SomeDeity\n  | Creature { creatureName :: Text, creatureAge :: Int }\n  | Demigod Text Text\n  | Zeus\n  deriving (Generic, GQLType)"),"\n        "),(0,r.kt)("p",null,"where ",(0,r.kt)("inlineCode",{parentName:"p"},"Deity")," is an object."),(0,r.kt)("p",null,"As we see, there are different kinds of unions. ",(0,r.kt)("inlineCode",{parentName:"p"},"Morpheus")," handles them all."),(0,r.kt)("p",null,"This type will be represented as"),(0,r.kt)("deckgo-highlight-code",{language:"graphql",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",(0,r.kt)("code",{parentName:"deckgo-highlight-code",slot:"code"},"union Character = Deity | SomeDeity | Creature | SomeMulti | Zeus\n\ntype SomeDeity {\n  _0: Deity!\n}\n\ntype Creature {\n  creatureName: String!\n  creatureAge: Int!\n}\n\ntype Demigod {\n  _0: Int!\n  _1: String!\n}\n\ntype Zeus {\n  _: Unit!\n}"),"\n        "),(0,r.kt)("p",null,"By default, union members will be generated with wrapper objects.\nThere is one exception to this: if a constructor of a type is the type name concatenated with the name of the contained type, it will be referenced directly.\nThat is, given:"),(0,r.kt)("deckgo-highlight-code",{language:"haskell",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",(0,r.kt)("code",{parentName:"deckgo-highlight-code",slot:"code"},"data Song = { songName :: Text, songDuration :: Float } deriving (Generic, GQLType)\n\ndata Skit = { skitName :: Text, skitDuration :: Float } deriving (Generic, GQLType)\n\ndata WrappedNode\n  = WrappedSong Song\n  | WrappedSkit Skit\n  deriving (Generic, GQLType)\n\ndata NonWrapped\n  = NonWrappedSong Song\n  | NonWrappedSkit Skit\n  deriving (Generic, GQLType)\n"),"\n        "),(0,r.kt)("p",null,"You will get the following schema:"),(0,r.kt)("deckgo-highlight-code",{language:"graphql",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",(0,r.kt)("code",{parentName:"deckgo-highlight-code",slot:"code"},"# has wrapper types\nunion WrappedNode = WrappedSong | WrappedSkit\n\n# is a direct union\nunion NonWrapped = Song | Skit\n\ntype WrappedSong {\n  _0: Song!\n}\n\ntype WrappedSKit {\n  _0: Skit!\n}\n\ntype Song {\n  songDuration: Float!\n  songName: String!\n}\n\ntype Skit {\n  skitDuration: Float!\n  skitName: String!\n}"),"\n        "),(0,r.kt)("ul",null,(0,r.kt)("li",{parentName:"ul"},(0,r.kt)("p",{parentName:"li"},"for all other unions will be generated new object type. for types without record syntax, fields will be automatically indexed.")),(0,r.kt)("li",{parentName:"ul"},(0,r.kt)("p",{parentName:"li"},"empty constructors will get field ",(0,r.kt)("inlineCode",{parentName:"p"},"_"),"associaced with type ",(0,r.kt)("inlineCode",{parentName:"p"},"Unit"),"."))),(0,r.kt)(l.$,{id:"inputs",level:2,mdxType:"Section"},"Input types"),(0,r.kt)("p",null,"Like object types, input types are represented by Haskell records.\nHowever, they are not permitted to have monad parameters, as they represent serialisable values."),(0,r.kt)("deckgo-highlight-code",{language:"haskell",terminal:"carbon",theme:"one-dark","line-numbers":"true"},"\n          ",(0,r.kt)("code",{parentName:"deckgo-highlight-code",slot:"code"},"data Deity = Deity\n  { name :: Text         -- Non-Nullable Field\n  , power :: Maybe Text   -- Nullable Field\n  } deriving\n    ( Generic\n    , GQLType\n    )"),"\n        "))}u.isMDXComponent=!0}}]);
//# sourceMappingURL=component---src-pages-server-mdx-7a80b08c532c5fdf6ac9.js.map