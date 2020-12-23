"
I'm a method generator/compiler.
I generate methods from the parser information. In particular I generate the bytecode for the method.
I holder a reference to the class generator. 


"
Class {
	#name : #SOMMethodGenerator,
	#superclass : #Object,
	#instVars : [
		'signature',
		'holder',
		'outer',
		'arguments',
		'isPrimitive',
		'onClassSide',
		'locals',
		'literals',
		'bytecode',
		'isFinished',
		'isBlock'
	],
	#category : #'AweSOM-Compiler'
}

{ #category : #'as yet unclassified' }
SOMMethodGenerator class >> blockIn: mgenc [ 
	^ self new
		somHolder: mgenc somHolder;
		outer: mgenc;
		yourself
]

{ #category : #'as yet unclassified' }
SOMMethodGenerator class >> named: n [

	^ self new
		signature: n asSymbol;
		yourself
]

{ #category : #'update information' }
SOMMethodGenerator >> addArgumentIfAbsent: argName [

	(self arguments includes: argName) ifTrue: [^ false].
	self arguments add: argName.
	^ true
]

{ #category : #'update information' }
SOMMethodGenerator >> addLiteralIfAbsent: literal [
	"Add if not present and return the index of a literal."
	
	| idx |
	idx := self literals identityIndexOf: literal.
	idx isZero ifFalse: [^ idx].
	self literals add: literal.
	^ self literals size
]

{ #category : #'update information' }
SOMMethodGenerator >> addLocalIfAbsent: varName [

	(self locals includes: varName) ifTrue: [^ false].
	self locals add: varName.
	^ true
]

{ #category : #accessing }
SOMMethodGenerator >> arguments [

	^ arguments
]

{ #category : #accessing }
SOMMethodGenerator >> arguments: anObject [

	arguments := anObject
]

{ #category : #assembling }
SOMMethodGenerator >> assemble: holderClass [

	| compileClass |
	self flag: #'AreYouDead?'.
	self halt.
	compileClass := self onClassSide
		ifTrue: [holderClass class]
		ifFalse: [holderClass].

	compileClass compile: (String streamContents: [:s | s
		nextPutAll: self combineSelectorAndArgs; cr])
]

{ #category : #assembling }
SOMMethodGenerator >> assembleIn: universe [
	"Define a SOMMethod object corresponding to the receiver and ready to be interpreted."
	
	^ self isPrimitive
		ifTrue: [SOMPrimitive
			inUniverse: universe
			named: self signature
			numArgs: arguments size]
		ifFalse: [ (SOMMethod
			inUniverse: universe
			named: self signature
			numArgs: self arguments size
			numLocals: self locals size
			maxStackDepth: self computeMaxStackDepth
			bytecodes: bytecode asArray
			holder: universe globalNil
			lexicalContext: universe globalNil)
				assignLexicalContexts ].
]

{ #category : #bytecode }
SOMMethodGenerator >> bcDup [
	
	^ self bytecode add: (SOMBCDup in: self)
]

{ #category : #bytecode }
SOMMethodGenerator >> bcHalt [

	self bytecode add: SOMBCHalt new.
]

{ #category : #bytecode }
SOMMethodGenerator >> bcPop [

	self bytecode add: (SOMBCPop in: self)
]

{ #category : #bytecode }
SOMMethodGenerator >> bcPopArgumentIndex: idx ctxIndex: ctxIdx [

	self bytecode add: (SOMBCPopArgument in: self index: idx contextIndex: ctxIdx)
]

{ #category : #bytecode }
SOMMethodGenerator >> bcPopField: fieldName [

	| idx fieldIdx bc |
	self assert: (self hasField: fieldName).
	idx := self addLiteralIfAbsent: fieldName.
	fieldIdx := holder fieldIndex: fieldName.
	bc := SOMBCPopField in: self index: idx.
	bc fieldIndex: fieldIdx.
	^ self bytecode add: bc.

]

{ #category : #bytecode }
SOMMethodGenerator >> bcPopLocalIndex: idx ctxIndex: ctxIdx [

	self bytecode add: (SOMBCPopLocal in: self index: idx contextIndex: ctxIdx).
]

{ #category : #bytecode }
SOMMethodGenerator >> bcPushArgumentIndex: idx ctxIndex: ctxIdx [

	self bytecode add: (SOMBCPushArgument in: self index: idx contextIndex: ctxIdx).
]

{ #category : #bytecode }
SOMMethodGenerator >> bcPushBlock: method [
	
	| idx |
	idx := self addLiteralIfAbsent: method.
	^ self bytecode add: (SOMBCPushBlock in: self index: idx)
]

{ #category : #bytecode }
SOMMethodGenerator >> bcPushConstant: const [

	| literalIndex |
	literalIndex := self addLiteralIfAbsent: const.
	self bytecode add: (SOMBCPushConstant in: self index: literalIndex).
	^ literalIndex
]

{ #category : #bytecode }
SOMMethodGenerator >> bcPushField: fieldName [

	| idx fieldIdx bc |
	self assert: [holder isNil or: [self hasField: fieldName]].
	idx := self addLiteralIfAbsent: fieldName.
	fieldIdx := holder fieldIndex: fieldName.
	bc := SOMBCPushField in: self index: idx.
	bc fieldIndex: fieldIdx.
	^ self bytecode add: bc
]

{ #category : #bytecode }
SOMMethodGenerator >> bcPushGlobal: global [

	| idx |
	idx := self addLiteralIfAbsent: global.
	^ self bytecode add: (SOMBCPushGlobal in: self index: idx)
]

{ #category : #bytecode }
SOMMethodGenerator >> bcPushLocalIndex: idx ctxIndex: ctxIdx [

	self bytecode add: (SOMBCPushLocal in: self index: idx contextIndex: ctxIdx)
]

{ #category : #bytecode }
SOMMethodGenerator >> bcReturnLocal [

	^ self bytecode add: (SOMBCReturnLocal in: self)
]

{ #category : #bytecode }
SOMMethodGenerator >> bcReturnNonLocal [

	^ self bytecode add: (SOMBCReturnNonLocal in: self)
]

{ #category : #bytecode }
SOMMethodGenerator >> bcSend: selector [

	| idx |
	self assert: selector isSymbol.
	idx := self addLiteralIfAbsent: selector.
	^ self bytecode add: (SOMBCSend in: self index: idx numArgs: selector numArgs)
]

{ #category : #bytecode }
SOMMethodGenerator >> bcSuperSend: selector [

	| idx |
	self assert: selector isSymbol.
	idx := self addLiteralIfAbsent: selector.
	^ self bytecode add: (SOMBCSuperSend in: self index: idx numArgs: selector numArgs).
]

{ #category : #accessing }
SOMMethodGenerator >> bytecode [
	^ bytecode
]

{ #category : #accessing }
SOMMethodGenerator >> bytecode: anObject [

	bytecode := anObject
]

{ #category : #bytecode }
SOMMethodGenerator >> bytecodeCount [

	^ self bytecode 
		inject: 0
		into: [ :sum :ea | sum + ea length ]
]

{ #category : #printing }
SOMMethodGenerator >> bytecodeString [

	^ String streamContents: [:s |
		self
			bytecodeStringTab: 0
			stream: s].
]

{ #category : #printing }
SOMMethodGenerator >> bytecodeStringTab: tabWidth stream: s [

	self bytecode do: [:ea |
		tabWidth timesRepeat: [s tab].
		ea printOn: s.
		s cr.
		(ea isKindOf: SOMBCPushBlock) ifTrue: [
			(ea mgenc literals at: ea index) bytecodes first mgenc
				bytecodeStringTab: tabWidth+1
				stream: s.]].
]

{ #category : #assembling }
SOMMethodGenerator >> combineSelectorAndArgs [

	| parts args |
	args := self arguments allButFirst. "First is self"
	args ifEmpty: [^ self signature].
	args size = 1 ifTrue: [^ self signature , ' ' , args first].
	parts := (self signature substrings: ':')
		with: args
		collect: [:sig :arg | sig , ': ' , arg].
	"Neeeeed join!!!"
	^ (parts inject: '' into: [:all :ea | all , ' ' , ea]) trimBoth.
]

{ #category : #'stack size' }
SOMMethodGenerator >> computeMaxStackDepth [

	| depth |
	depth := 0.
	^ self bytecode inject: 0 into: [:maxDepth :ea |
		depth := depth + ea stackDepth.
		depth > maxDepth
			ifTrue: [depth]
			ifFalse: [maxDepth]].
]

{ #category : #bytecode }
SOMMethodGenerator >> emitSend: selector isSuper: isSuper [

	isSuper
		ifTrue: [self bcSuperSend: selector]
		ifFalse: [self bcSend: selector]
]

{ #category : #lookup }
SOMMethodGenerator >> findVariable: varName context: ctx ifFound: aBlock [

	| idx isArgument |
	isArgument := false.

	idx := locals indexOf: varName.
	idx = 0 ifTrue: [
		idx := arguments indexOf: varName.
		idx = 0
			ifTrue: [
				outer ifNil: [ ^ false ]
				ifNotNil: [
					^ outer findVariable: varName context: ctx + 1 ifFound: aBlock ]]
			ifFalse: [ isArgument := true ]].
	
	^ aBlock value: idx value: ctx value: isArgument
]

{ #category : #'update information' }
SOMMethodGenerator >> finished [

	isFinished := true
]

{ #category : #lookup }
SOMMethodGenerator >> hasField: field [
	^ holder hasField: field
]

{ #category : #accessing }
SOMMethodGenerator >> holder [

	^ holder
]

{ #category : #accessing }
SOMMethodGenerator >> holder: anObject [

	holder := anObject
]

{ #category : #initialize }
SOMMethodGenerator >> initialize [

	super initialize.
	self
		isPrimitive: false;
		onClassSide: false;
		locals: OrderedCollection new;
		literals: OrderedCollection new;
		bytecode: OrderedCollection new;
		arguments: OrderedCollection new;
		isFinished: false;
		isBlockMethod: false.
]

{ #category : #accessing }
SOMMethodGenerator >> isBlockMethod [

	^ isBlock
]

{ #category : #accessing }
SOMMethodGenerator >> isBlockMethod: bool [

	isBlock := bool
]

{ #category : #accessing }
SOMMethodGenerator >> isFinished [

	^ isFinished
]

{ #category : #accessing }
SOMMethodGenerator >> isFinished: bool [

	isFinished := bool
]

{ #category : #accessing }
SOMMethodGenerator >> isPrimitive [
	^ isPrimitive
]

{ #category : #accessing }
SOMMethodGenerator >> isPrimitive: anObject [

	isPrimitive := anObject
]

{ #category : #accessing }
SOMMethodGenerator >> literals [

	^ literals
]

{ #category : #accessing }
SOMMethodGenerator >> literals: anObject [

	literals := anObject
]

{ #category : #accessing }
SOMMethodGenerator >> locals [

	^ locals
]

{ #category : #accessing }
SOMMethodGenerator >> locals: anObject [

	locals := anObject
]

{ #category : #accessing }
SOMMethodGenerator >> onClassSide [

	^ onClassSide
]

{ #category : #accessing }
SOMMethodGenerator >> onClassSide: anObject [

	onClassSide := anObject
]

{ #category : #accessing }
SOMMethodGenerator >> outer [
	^ outer
]

{ #category : #accessing }
SOMMethodGenerator >> outer: anObject [
	outer := anObject
]

{ #category : #printing }
SOMMethodGenerator >> printOn: stream [


	self signature ifNil: [
		super printOn: stream.
		^ self].
	stream
		nextPutAll: '<SOMMgenc signature: ';
		nextPutAll: self signature;
		nextPut: $>.
]

{ #category : #bytecode }
SOMMethodGenerator >> removeLastBytecode [

	self bytecode removeLast
]

{ #category : #bytecode }
SOMMethodGenerator >> returnSelf [

	self bcPushArgumentIndex: 1 ctxIndex: 1.
	self bcReturnLocal.
]

{ #category : #accessing }
SOMMethodGenerator >> signature [

	^ signature
]

{ #category : #accessing }
SOMMethodGenerator >> signature: anObject [

	signature := anObject
]

{ #category : #accessing }
SOMMethodGenerator >> somHolder [

	^ holder
]

{ #category : #accessing }
SOMMethodGenerator >> somHolder: anObject [

	holder := anObject
]

{ #category : #'update information' }
SOMMethodGenerator >> updateLiteralAt: index with: literal [

	self literals at: index put: literal
]
