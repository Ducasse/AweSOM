"
Here is the typical class definition with fields and methods 



Board = (
  | view width height board |

  width = ( ^width )
  width: val = ( width := val. )

  height = ( ^height )
  height: val = ( height := val )

  board = ( ^board )
  board: val = ( board := val )

  view = ( ^view )

  addApple = (
    | added x y newApple |
    added := false.

    [ added ] whileFalse: [
      x := 1 atRandom % width. ""$x = rand(0, $this->width - 1);""
      y := 1 atRandom % height.

      x := x + 1.
      y := y + 1.

      (self board at: x) isNil ifTrue: [
        self board at: x put: (Array new: height).
      ].

      ((self board at: x) at: y) isNil ifTrue: [
        newApple := Apple newWithX: x Y: y.
        (self board at: x) at: y put: newApple.
        added := true.
        view isNil ifFalse: [
          view addApple: newApple.
        ].
      ]
    ]
  )

  view: value = (
    view := value.
    value board: board.
    value updateCompletely.
  )

  isAppleAtX: x Y: y = (
    ((board at: x) isNil) ifFalse: [
      ((board at: x) at: y) isNil ifFalse: [
        ^((board at: x) at: y) class == Apple
      ]
    ].
    ^false
  )

  isSnakeAtX: x Y: y = (
    ((board at: x) isNil) ifFalse: [
      ((board at: x) at: y) isNil ifFalse: [
        ^((board at: x) at: y) class == SnakeElement
      ]
    ].
    ^false
  )

  remove: element = (
    (self board at: (element x)) at: (element y) put: nil.
    self view remove: element
  )

  add: element = (
    (self board at: element x) isNil ifTrue: [
      self board at: (element x) put: (Array new: height).
    ].
    (self board at: (element x)) at: (element y) put: element.
    view add: element
  )

  ----
"
Class {
	#name : #SOMClassParser,
	#superclass : #SOMParser,
	#category : #'AweSOM-Parsing'
}

{ #category : #patterns }
SOMClassParser >> classBody [
	self expect: #newTerm.
	
	self classSide.
	
	self classInstanceSwitch ifTrue: [
		cgenc toggleClassSide.
		self classSide.].
	
	self expect: #endTerm.
]

{ #category : #patterns }
SOMClassParser >> classInstanceSwitch [
	^ self accept: #seperator.
]

{ #category : #patterns }
SOMClassParser >> classSide [
	self vars.
	
	[self symIsIdentifier     or: [
	 sym == #keyword          or: [
	 sym == #operatorSequence or: [
	 self symIn: BinaryOpSyms]]]]
		whileTrue: [
			self foreignParseMethod].
]

{ #category : #patterns }
SOMClassParser >> classStart [
	| superName |
	cgenc theName: self identifier.
	
	self expect: #equal.
	
	superName := sym == #identifier
		ifTrue:  [ self identifier ]
		ifFalse: [ #Object ].
	cgenc superName: superName.
	
	"Load the super class, if it is not nil (to break dependency cycle)"
	superName == #nil ifFalse: [ 
		| superClass |
		superClass := universe loadSOMClass: superName.
		
		superClass ifNil: [
			SOMParseError signalWith: 'Super class "', superName asString, '" could not be loaded'
							 expectedSym: nil and: self ].

		cgenc addInstanceFields: superClass allInstanceFields.
		cgenc addClassFields: superClass somClass allInstanceFields.		
	].
	

		
]

{ #category : #patterns }
SOMClassParser >> classdef [
	self classStart.
	self classBody.
]

{ #category : #patterns }
SOMClassParser >> foreignParseMethod [
	| parser result |
	parser := self methodParser.
	parser parseState: self parseState.
	
	result := parser apply: #method.
	
	cgenc addMethod: result.
	self parseState: parser parseState.
	^ result
]

{ #category : #'initialize-release' }
SOMClassParser >> initialize [
	super initialize.
	
	self cgenc: SOMClassGenerationContext new.
]

{ #category : #helper }
SOMClassParser >> methodParser [

	^ super methodParser
		cgenc: self cgenc;
		yourself.
]

{ #category : #parsing }
SOMClassParser >> start [
	self classdef.
	^ cgenc
]

{ #category : #patterns }
SOMClassParser >> vars [
	(self accept: #or) ifTrue: [
		[self symIsIdentifier] whileTrue: [
			cgenc addField: self variable.
		].
		
		self expect: #or.
	]
]
