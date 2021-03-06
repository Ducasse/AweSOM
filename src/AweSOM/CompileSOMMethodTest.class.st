Class {
	#name : #CompileSOMMethodTest,
	#superclass : #TestCaseWithUniverse,
	#category : #'AweSOM-Compiler-Test'
}

{ #category : #create }
CompileSOMMethodTest >> createMethodGeneratorFromSource: source [
	
	| parser |
	parser := SOMMethodParser inUniverse: universe onSource: source from: 'test'.
	^ parser apply: #method.
]

{ #category : #tests }
CompileSOMMethodTest >> test01BuildSimpleMethod [
	| mgenc method |
	mgenc := SOMMethodGenerator named: 'a:b:c:'.
	method := mgenc assembleIn: universe.
	self 
		assert: method somSignature symbol
		equals: #a:b:c:
]

{ #category : #tests }
CompileSOMMethodTest >> test02BuildByteCode [
	| mgenc method |
	mgenc := self createMethodGeneratorFromSource: 'x: a = (|aLocal| ^a)'.
	method := mgenc assembleIn: universe.
	{SOMBCPushArgument. SOMBCReturnLocal} withIndexDo: [:each :i|
		self assert: ((method bytecodeAt: i) isKindOf: each)].
	self assert: method numberOfLocals equals: 1.
	self assert: method numberOfArguments equals: 2.

]

{ #category : #tests }
CompileSOMMethodTest >> test02BuildMethodWithConstants [
	| mgenc method |
	mgenc := self createMethodGeneratorFromSource: 'x: a = (a foo: 42)'.
	method := mgenc assembleIn: universe.
	"waiting for arvid's patch"
	"self assert: (method constantForBytecodeIndex: 1) symbol equals: #foo."
]
