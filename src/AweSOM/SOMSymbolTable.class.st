Class {
	#name : #SOMSymbolTable,
	#superclass : #IdentityDictionary,
	#instVars : [
		'universe'
	],
	#category : #'AweSOM-VM'
}

{ #category : #'as yet unclassified' }
SOMSymbolTable class >> in: universe [

	^ self new
		universe: universe;
		yourself.
]

{ #category : #accessing }
SOMSymbolTable >> somSymbolFor: aPharoSymbol [

	^ self
		at: aPharoSymbol 
		ifAbsentPut: [SOMSymbol
			inUniverse: self universe
			string: aPharoSymbol].
]

{ #category : #accessing }
SOMSymbolTable >> universe [
	^ universe
]

{ #category : #accessing }
SOMSymbolTable >> universe: anObject [
	universe := anObject
]
