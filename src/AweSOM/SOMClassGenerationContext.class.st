"
I'm a kind of representation of a class (the Context suffix in my name is just confusing and has nothing to do with the context of a VM).

"
Class {
	#name : #SOMClassGenerationContext,
	#superclass : #Object,
	#instVars : [
		'superName',
		'isClassSide',
		'instanceFields',
		'instanceMethods',
		'classFields',
		'classMethods',
		'theName'
	],
	#category : #'AweSOM-Compiler'
}

{ #category : #adding }
SOMClassGenerationContext >> addClassField: fieldName [

	classFields add: fieldName
]

{ #category : #adding }
SOMClassGenerationContext >> addClassFields: fields [

	classFields addAll: fields
]

{ #category : #adding }
SOMClassGenerationContext >> addField: field [

	self isClassSide
		ifTrue:  [ classFields add: field ]
		ifFalse: [ instanceFields add: field ] 
]

{ #category : #adding }
SOMClassGenerationContext >> addFields: fieldNames [

	^ self isClassSide
		ifTrue: [ classFields addAll: fieldNames ]
		ifFalse: [ instanceFields addAll: fieldNames ]
]

{ #category : #adding }
SOMClassGenerationContext >> addInstanceField: field [

	instanceFields add: field
]

{ #category : #adding }
SOMClassGenerationContext >> addInstanceFields: fields [

	instanceFields addAll: fields
]

{ #category : #adding }
SOMClassGenerationContext >> addMethod: methodGenContext [

	^ self isClassSide
		ifFalse: [ self instanceMethods add: methodGenContext ]
		ifTrue: [
			methodGenContext onClassSide: true.
			self classMethods add: methodGenContext ]
]

{ #category : #assembling }
SOMClassGenerationContext >> assembleIn: universe [

	^ self
		assembleIn: universe
		stub: (self createEmptyClassIn: universe)
]

{ #category : #assembling }
SOMClassGenerationContext >> assembleIn: universe stub: classStub [

	self
		initInstanceSideOf: classStub in: universe;
		initClassSideOf: classStub in: universe;
		initFieldsOf: classStub in: universe.
	^ classStub
]

{ #category : #accessing }
SOMClassGenerationContext >> classFields [

	^ classFields
]

{ #category : #accessing }
SOMClassGenerationContext >> classMethods [

	^ classMethods
]

{ #category : #assembling }
SOMClassGenerationContext >> createEmptyClassIn: universe [
	"Load the superclass of the receiver from the source on disc and create an empty class in the current universe with the superclass the loaded class."
	
	| superclass |
	superclass := universe
		globalAt: self superName
		ifAbsent: [ universe loadSOMClass: self superName ].
	^ SOMClass
		inUniverse: universe
		withSomSuperClass: superclass
]

{ #category : #adding }
SOMClassGenerationContext >> fieldIndex: fieldName [

	^ self isClassSide
		ifTrue:  [ classFields indexOf: fieldName ]
		ifFalse: [ instanceFields indexOf: fieldName ]
]

{ #category : #testing }
SOMClassGenerationContext >> hasField: fieldName [

	^ self isClassSide
		ifTrue:  [ self classFields includes: fieldName ]
		ifFalse: [ self instanceFields includes: fieldName ]
]

{ #category : #assembling }
SOMClassGenerationContext >> initClassSideOf: somClass in: universe [
	"Initialize the class side of the receiver"
	
	| fields methods |
	self flag: #rkrk. "Duplication with #initInstanceSideOf:in:"
	self flag: #ask. "why not using nilObject := universe globalNil. as in initFieldsOf:in:"
	somClass somClass somName: (universe newSymbol: self theName , ' class').
	fields := self classFields collect: [:each | universe newSymbol: each].
	somClass somClass somInstanceFields: (universe newArrayWithAll: fields).
	methods := self classMethods collect: [:each | each assembleIn: universe].
	somClass somClass somInstanceInvokables: (universe newArrayWithAll: methods)
]

{ #category : #assembling }
SOMClassGenerationContext >> initFieldsOf: somClass in: universe [
	"Initialize fields of the argument and pay attention that nil default value of fields are somNil and not PharoNil."
	
	| nAdditionalFields nilObject |
	self flag: #ask. 
	"how class instance variables are managed. First this method is not invoked twice: one for class and metaclass
	as we could have expected. Second it looks like the additional fields "
	nAdditionalFields := somClass somClass somInstanceFields size.
	nilObject := universe globalNil.
	somClass fields: (Array new: nAdditionalFields).
	somClass numberOfFields - nAdditionalFields + 1
		to: somClass numberOfFields
		do: [:i | somClass fieldAtIndex: i put: nilObject]
]

{ #category : #assembling }
SOMClassGenerationContext >> initInstanceSideOf: somClass in: universe [

	| fields methods |
	somClass somName: (universe newSymbol: self theName).
	fields := self instanceFields collect: [:each | universe newSymbol: each].
	somClass somInstanceFields: (universe newArrayWithAll: fields).
	methods := self instanceMethods collect: [:each | each assembleIn: universe].
	somClass somInstanceInvokables: (universe newArrayWithAll: methods)
]

{ #category : #initialization }
SOMClassGenerationContext >> initialize [

	super initialize.
	
	isClassSide := false.
	superName := #nil.
	instanceFields := OrderedCollection new.
	classFields := OrderedCollection new.
	instanceMethods := OrderedCollection new.
	classMethods := OrderedCollection new.
	theName := ''.
]

{ #category : #accessing }
SOMClassGenerationContext >> instanceFields [

	^ instanceFields
]

{ #category : #accessing }
SOMClassGenerationContext >> instanceFields: anObject [

	instanceFields := anObject
]

{ #category : #accessing }
SOMClassGenerationContext >> instanceMethods [

	^ instanceMethods
]

{ #category : #accessing }
SOMClassGenerationContext >> isClassSide [

	^ isClassSide
]

{ #category : #accessing }
SOMClassGenerationContext >> isClassSide: anObject [

	isClassSide := anObject
]

{ #category : #accessing }
SOMClassGenerationContext >> superName [

	^ superName
]

{ #category : #accessing }
SOMClassGenerationContext >> superName: anObject [

	superName := anObject
]

{ #category : #accessing }
SOMClassGenerationContext >> theName [

	^ theName
]

{ #category : #accessing }
SOMClassGenerationContext >> theName: aString [

	theName := aString
]

{ #category : #accessing }
SOMClassGenerationContext >> toggleClassSide [

	self isClassSide: self isClassSide not
]
