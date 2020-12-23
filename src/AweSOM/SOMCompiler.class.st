"
I'm facade delegating to SOMMethodGenerationContext (a method compiler) and SOMClassGenerationContext.
My main API method is loadAndCompileSOMClass:stub:
"
Class {
	#name : #SOMCompiler,
	#superclass : #Object,
	#instVars : [
		'universe',
		'classPaths'
	],
	#category : #'AweSOM-Compiler'
}

{ #category : #'as yet unclassified' }
SOMCompiler class >> inUniverse: universe on: classPaths [

	^ self new
		classPaths: classPaths;
		universe: universe;
		yourself.
]

{ #category : #'file access' }
SOMCompiler >> classFileExtension [

	^ '.som'
]

{ #category : #accessing }
SOMCompiler >> classPaths [

	^ classPaths
]

{ #category : #accessing }
SOMCompiler >> classPaths: anObject [

	classPaths := anObject
]

{ #category : #compiling }
SOMCompiler >> compileSOMClassSource: source stub: classStubOrNil from: aFileName [

	| classGenerator |
	classGenerator := (SOMClassParser inUniverse: universe onSource: source from: aFileName) parseClass.
	^ classStubOrNil
		ifNil: [ classGenerator assembleIn: universe]
		ifNotNil: [ classGenerator assembleIn: universe stub: classStubOrNil].
]

{ #category : #loading }
SOMCompiler >> loadAndCompileSOMClass: className stub: classStubOrNil [

	| sourceAndFile |
	sourceAndFile := self sourceAndClassFileOf: className.
	sourceAndFile ifNil: [^ nil].
	^ self compileSOMClassSource: (sourceAndFile at: 1) stub: classStubOrNil from: (sourceAndFile at: 2).
]

{ #category : #'file access' }
SOMCompiler >> sourceAndClassFileOf: className [
	"Return an array with the source and the class file of the corresponding file."
	
	| classFile theDir source stream |
	classFile := className , self classFileExtension.
	theDir := (self classPaths
		collect: [:path | path asFileReference ])
		detect: [:dir | (dir resolveString: classFile) exists ]
		ifNone: [^ nil].
	"theDir ifNil: [self error: 'Cannot find class in classPath']."
	stream := (theDir resolveString: classFile) readStream.
	source := stream contents.
	stream close.
	^ {source . classFile}
]

{ #category : #accessing }
SOMCompiler >> universe [

	^ universe
]

{ #category : #accessing }
SOMCompiler >> universe: aSOMUniverse [

	universe := aSOMUniverse
]
