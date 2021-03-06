Class {
	#name : #ParseMethodTest,
	#superclass : #ParseClassTest,
	#category : #'AweSOM-Parsing-Test'
}

{ #category : #running }
ParseMethodTest >> parserClass [

	^ SOMMethodParser
]

{ #category : #running }
ParseMethodTest >> setUpParser: source [

	super setUpParser: source.
	parser
		"fakeMgenc;"
		fakeCgenc.
]

{ #category : #tests }
ParseMethodTest >> test01SimpleMethodDef [

	self setUpParser: 'x = (1)'.
	result := parser apply: #method.
	self assert: (result isKindOf: SOMMethodGenerator).
	self 
		assert: result signature
		equals: #x
]

{ #category : #tests }
ParseMethodTest >> test02ParseArguments [

	self setUpParser: 'x: abc y: def4 = ( 1 + 1 )'.
	result := parser apply: #method.
	self assert: result arguments size = 3. "First is self"
	self assert: (result arguments includes: 'abc').
	self assert: (result arguments includes: 'def4').
]

{ #category : #tests }
ParseMethodTest >> test04Primitive [

	| res |
	self setUpParser: '"Accessing" at: index = primitive'.
	res := parser apply: #method.
	self assert: res isPrimitive.
]

{ #category : #tests }
ParseMethodTest >> test05PrimitiveMethodGeneratesBody [

	self setUpParser: 'test = primitive'.
	parser fakeCgenc. "className = Dummy"
	result := parser apply: #method.
]

{ #category : #tests }
ParseMethodTest >> test06PrimitiveWithParameters [

	self setUpParser: 'test: a test: b = primitive'.
	result := parser apply: #method.
]

{ #category : #tests }
ParseMethodTest >> test07LocalVars [

	self setUpParser: 'x = (| abc |)'.
	result := parser apply: #method.
	self assert: result locals equals: {'abc'} asOrderedCollection.
]

{ #category : #tests }
ParseMethodTest >> test08SystemResolveMethod [

	| src |
	src := 'resolve: symbol = (
        | class currentclass |
        (self global: symbol) == nil ifFalse: [ ^self global: symbol ].        
        class := self load: symbol.
        (class == nil) ifFalse: [
             currentclass := class.
             [ (self global: (currentclass name)) == nil ] whileTrue: [
                self global: (currentclass name) put: currentclass.
                currentclass := currentclass superclass. ].
            ^class ].
        self error: ''Unable to resolve '' + symbol
    )'.
	self setUpParser: src.
	result := parser apply: #method.
	"self halt."
]

{ #category : #tests }
ParseMethodTest >> test09HashEntryRun [

	| src |
	src := 'run = ("(")'.
	self setUpParser: src.
	result := parser apply: #method.
"	self halt."
]

{ #category : #tests }
ParseMethodTest >> test10BigIntegerTestRun [

	| src |
	src := 'run: harness = (-1)'.
	self setUpParser: src.
	result := parser apply: #method.
"	self halt."
]

{ #category : #tests }
ParseMethodTest >> test11ReflectionTestRun [

	| src |
	src := 'run: harness = (self x: #==)'.
	self setUpParser: src.
	result := parser apply: #method.
"	self halt."
]

{ #category : #tests }
ParseMethodTest >> test12SimpleOperatorMethodDef [

	self setUpParser: '& bool = ()'.
	result := parser apply: #method.
	self assert: (result isKindOf: SOMMethodGenerator).
	self assert: result signature 			equals: '&'.
	self assert: result arguments size  		equals: 2.
	self assert: result arguments first 		equals: #self.
	self assert: result arguments second 	equals: #bool.
]
