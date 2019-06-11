"
I am a interactive layer to use refactoring without use views.

Instance Variables
-----------------------------------------------------------------
method: CompiledMethod
interval: Interval
node:	RBNode

Example
-----------------------------------------------------------------
I can be used in playground, for example:

GIVEN:
======
Object subclass: #Example
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'Refactoring-InteractiveLayer'
	
Example >> example
	| a b c |
	a := 3.
	b := 5.
	c := a + b.
	c := c + a

THEN EXECUTE: 
=============
RBInteractiveLayer new inlineTempIn: 'example' withClass: Example for: (44 to: 44).

RESULT: 
=======
Example >> example
	| b c |
	b := 5.
	c := 3 + b.
	c := c + 3

Also I can used in commands, for an example you can review the execute method of SycSourceCodeCommand class
"
Class {
	#name : #RBInteractiveLayer,
	#superclass : #Object,
	#instVars : [
		'method',
		'interval',
		'node'
	],
	#category : #'Refactoring-InteractiveLayer'
}

{ #category : #'as yet unclassified' }
RBInteractiveLayer class >> class: aClass method: aMethod interval: anInterval node: aNode [
	^ self new 
		class: aClass;
		method: aMethod;
		interval: anInterval ;
		node: aNode
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer class >> class: aClass method: aMethod node: aNode [
	^ self new 
		class: aClass;
		method: aMethod;
		node: aNode
]

{ #category : #initialization }
RBInteractiveLayer class >> initializeMethod: aMethod class: aClass [
	^ self new initializeMethod: aMethod class: aClass interval: nil
]

{ #category : #initialization }
RBInteractiveLayer class >> initializeMethod: aMethod class: aClass interval: anInterval [
	^ self new initializeMethod: aMethod class: aClass interval: anInterval
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer class >> method: aMethod [
	^ self new 
		method: aMethod
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer class >> method: aMethod node: aNode [
	^ self new 
		method: aMethod;
		node: aNode
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> compiledMethodOf: aMethod from: aClass [
	"Return compiled method given a method name (string) and a class"
	
	| index |
	(aClass methods collect: #selector)
		withIndexDo: [ :each :i | 
			each = aMethod asSymbol
				ifTrue: [ index := i ] ].
	^ aClass methods at: index
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> executeRefactoring: refactoring [
	"Execute refactoring and when it has an error show an message UI of alert"
	
	[ refactoring execute ] on: RBRefactoringError do: [ :e | 
	UIManager default alert: e messageText ].
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> executeThis: refactoring [
	"Execute refactoring "
	
	^ self executeThis: refactoring with: #execute
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> executeThis: refactoring with: aSymbol [
	"Execute aSymbol refactoring method"
	
	[refactoring perform: aSymbol.
	^ refactoring ] on:RBRefactoringError do: [ :e | e signal]
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> extractMethod [
	"Return extract method refactoring"
	
	| refactoring selectedInterval dialog|
	selectedInterval := interval ifEmpty: [ node sourceInterval ].
	
	refactoring := RBExtractMethodRefactoring	
		extract: selectedInterval from: method selector in: method origin.
	self setUpOptionToUseExistingMethodDuring: refactoring.
	self setUpOptionToOverrideExistingMethodDuring: refactoring.
	refactoring setOption: #methodName toUse:  [ :ref :methodName |
		dialog := SycMethodNameEditor openOn: methodName.
		dialog cancelled ifTrue: [  CmdCommandAborted signal ].
		methodName].
	^ refactoring
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> extractMethodIn: aMethod withClass: aClass for: anInterval [
	"Method for use a extract method refactoring from a playground, 
	this run the execute method of refactoring as default"
	
	self initializeMethod: aMethod class: aClass interval: anInterval .
	self executeThis: (self extractMethod)
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> extractMethodWithPerform: aSymbol [
	"Method for use a extract method refactoring from a playground, 
	this run the aSymbol method of refactoring"

	| refactoring |
	refactoring := self extractMethod.
	^ self executeThis: refactoring with: aSymbol
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> extractTempIn: aMethod withClass: aClass for: anInterval withTempName: tempName [
	"Method for use a extract temporary refactoring from a playground, 
	this run the execute method of refactoring as default"

	self initializeMethod: aMethod class: aClass interval: anInterval .
	self executeThis: (self extractTempWithName: tempName)
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> extractTempWithName: newTempName [
	"Return extract temporary refactoring using method, node and newTempName"
	
	^ RBExtractToTemporaryRefactoring	
		extract: node sourceInterval
		to: newTempName
		from: method selector
		in: method origin
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> extractTempWithName: tempName withPerform: aSymbol [
	"Method for use a extract temporary refactoring from a playground, 
	this run the aSymbol method of refactoring"

	| refactoring |
	refactoring := self extractTempWithName: tempName .
	^ self executeThis: refactoring with: aSymbol
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> initializeMethod: aMethod class: aClass interval: anInterval [
	"Initialize method and node of this class given:
	aMethod: a string of method name
	aClass: class that owns the given method
	anInterval: interval to do a refactoring"
	
	interval := anInterval.
	method := self compiledMethodOf: aMethod from: aClass.
	node := method astForStylingInCalypso bestNodeFor: anInterval.
	node ifNil: [ node := method astForStylingInCalypso ]
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> inlineMethod [
	"Return inline method refactoring using method and node"
	
	^ RBInlineMethodRefactoring	
		inline: node sourceInterval
		inMethod: method selector
		forClass: method origin.
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> inlineMethodIn: aMethod withClass: aClass for: anInterval [
	"Method for use a inline method refactoring from a playground, 
	this run the execute method of refactoring as default"

	self initializeMethod: aMethod class: aClass interval: anInterval .
	self executeThis: (self inlineMethod)
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> inlineMethodWithPerform: aSymbol [
	"Method for use a inline method refactoring from a playground, 
	this run the aSymbol method of refactoring"
	
	| refactoring |
	refactoring := self inlineMethod.
	^ self executeThis: refactoring with: aSymbol
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> inlineTemp [
	"Return inline temporary refactoring using method and node"
	
	| assignment |
	assignment := node methodNode assignmentNodes
		detect: [ :each | each variable = node ].
	^ RBInlineTemporaryRefactoring
		inline: assignment sourceInterval
		from: method selector
		in: method origin
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> inlineTempIn: aMethod withClass: aClass for: anInterval [
	"Method for use a inline temporary refactoring from a playground, 
	this run the execute method of refactoring as default"

	self initializeMethod: aMethod class: aClass interval: anInterval .
	self executeThis: (self inlineTemp)
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> inlineTempWithPerform: aSymbol [
	"Method for use a inline temporary refactoring from a playground, 
	this run the aSymbol method of refactoring"

	| refactoring |
	refactoring := self inlineTemp.
	^ self executeThis: refactoring with: aSymbol
]

{ #category : #accessing }
RBInteractiveLayer >> interval [
	^ interval
]

{ #category : #accessing }
RBInteractiveLayer >> interval: anObject [
	interval := anObject
]

{ #category : #accessing }
RBInteractiveLayer >> method [
	^ method
]

{ #category : #accessing }
RBInteractiveLayer >> method: anObject [
	method := anObject
]

{ #category : #accessing }
RBInteractiveLayer >> node [
	^ node
]

{ #category : #accessing }
RBInteractiveLayer >> node: anObject [
	node := anObject
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> pushUpMethod [
	"Return push up method refactoring using method"
	
	^ RBPullUpMethodRefactoring 
		pullUp: {method selector} 
		from: method origin
	
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> pushUpMethod: aMethod inClass: aClass [
	"Method for use a push up method refactoring from a playground, 
	this run the execute method of refactoring as default"
	
	self initializeMethod: aMethod class: aClass interval: nil .
	self executeThis: (self pushUpMethod)
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> pushUpMethodWithPerform: aSymbol [ 
	"Method for use a push up method refactoring from a playground, 
	this run the aSymbol method of refactoring"
	
	| refactoring |
	refactoring := self pushUpMethod.
	^ self executeThis: refactoring with: aSymbol
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> renameTempIn: aMethod withClass: aClass for: anInterval withName: aString [
	"Method for use a rename temporary refactoring from a playground, 
	this run the execute method of refactoring as default"
	
	self initializeMethod: aMethod class: aClass interval: anInterval .
	self executeThis: (self renameTempWithName: aString)
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> renameTempWithName: newTempName [
	"Return rename temporary refactoring using method, node and newTempName"
	
	 ^ RBRenameTemporaryRefactoring	
		renameTemporaryFrom: node sourceInterval
		to: newTempName
		in: method origin
		selector: method selector
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> renameTempWithName: newName withPerform: aSymbol [
	"Method for use a rename temporary refactoring from a playground, 
	this run the aSymbol method of refactoring"

	| refactoring |
	refactoring := self renameTempWithName: newName.
	^ self executeThis: refactoring with: aSymbol
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> setUpOptionToOverrideExistingMethodDuring: aRefactoring [

	aRefactoring setOption: #alreadyDefined toUse:  [ :ref :aClass :selector | 
		ref refactoringWarning: 'Method ', selector printString, ' will override method in ', aClass name]. 
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> setUpOptionToUseExistingMethodDuring: aRefactoring [

	aRefactoring setOption: #useExistingMethod toUse:  [ :ref :selector | 
		UIManager default 
			confirm: 'Do you want use existing method ', selector printString, '?'
			label: 'Warninig']. 	
	
]
