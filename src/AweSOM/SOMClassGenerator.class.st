"
I'm responsible to generate a class from the information given by the parser.

My main method is assembleIn: and assembleIn:stub:

"
Class {
	#name : #SOMClassGenerator,
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
SOMClassGenerator >> addClassField: fieldName [

	classFields add: fieldName
]

{ #category : #adding }
SOMClassGenerator >> addClassFields: fields [

	classFields addAll: fields
]

{ #category : #adding }
SOMClassGenerator >> addField: field [

	self isClassSide
		ifTrue:  [ classFields add: field ]
		ifFalse: [ instanceFields add: field ] 
]

{ #category : #adding }
SOMClassGenerator >> addFields: fieldNames [

	^ self isClassSide
		ifTrue: [ classFields addAll: fieldNames ]
		ifFalse: [ instanceFields addAll: fieldNames ]
]

{ #category : #adding }
SOMClassGenerator >> addInstanceField: field [

	instanceFields add: field
]

{ #category : #adding }
SOMClassGenerator >> addInstanceFields: fields [

	instanceFields addAll: fields
]

{ #category : #adding }
SOMClassGenerator >> addMethod: methodGenContext [

	^ self isClassSide
		ifFalse: [ self instanceMethods add: methodGenContext ]
		ifTrue: [
			methodGenContext onClassSide: true.
			self classMethods add: methodGenContext ]
]

{ #category : #assembling }
SOMClassGenerator >> assembleIn: universe [
	"Define in the universe a SOMClass object. Note that the superclass of this class will be loaded from file."
	
	^ self
		assembleIn: universe
		stub: (self createEmptyClassIn: universe)
]

{ #category : #assembling }
SOMClassGenerator >> assembleIn: universe stub: classStub [

	self
		initInstanceSideOf: classStub in: universe;
		initClassSideOf: classStub in: universe;
		initFieldsOf: classStub in: universe.
	^ classStub
]

{ #category : #accessing }
SOMClassGenerator >> classFields [

	^ classFields
]

{ #category : #accessing }
SOMClassGenerator >> classMethods [

	^ classMethods
]

{ #category : #assembling }
SOMClassGenerator >> createEmptyClassIn: universe [
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
SOMClassGenerator >> fieldIndex: fieldName [

	^ self isClassSide
		ifTrue: [ classFields indexOf: fieldName ]
		ifFalse: [ instanceFields indexOf: fieldName ]
]

{ #category : #testing }
SOMClassGenerator >> hasField: fieldName [

	^ self isClassSide
		ifTrue:  [ self classFields includes: fieldName ]
		ifFalse: [ self instanceFields includes: fieldName ]
]

{ #category : #assembling }
SOMClassGenerator >> initClassSideOf: somClass in: universe [
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
SOMClassGenerator >> initFieldsOf: somClass in: universe [
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
SOMClassGenerator >> initInstanceSideOf: somClass in: universe [

	| fields methods |
	somClass somName: (universe newSymbol: self theName).
	fields := self instanceFields collect: [:each | universe newSymbol: each].
	somClass somInstanceFields: (universe newArrayWithAll: fields).
	methods := self instanceMethods collect: [:each | each assembleIn: universe].
	somClass somInstanceInvokables: (universe newArrayWithAll: methods)
]

{ #category : #initialization }
SOMClassGenerator >> initialize [

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
SOMClassGenerator >> instanceFields [

	^ instanceFields
]

{ #category : #accessing }
SOMClassGenerator >> instanceFields: anObject [

	instanceFields := anObject
]

{ #category : #accessing }
SOMClassGenerator >> instanceMethods [

	^ instanceMethods
]

{ #category : #accessing }
SOMClassGenerator >> isClassSide [

	^ isClassSide
]

{ #category : #accessing }
SOMClassGenerator >> isClassSide: anObject [

	isClassSide := anObject
]

{ #category : #accessing }
SOMClassGenerator >> superName [

	^ superName
]

{ #category : #accessing }
SOMClassGenerator >> superName: anObject [

	superName := anObject
]

{ #category : #accessing }
SOMClassGenerator >> theName [

	^ theName
]

{ #category : #accessing }
SOMClassGenerator >> theName: aString [

	theName := aString
]

{ #category : #accessing }
SOMClassGenerator >> toggleClassSide [

	self isClassSide: self isClassSide not
]
