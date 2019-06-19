Class {
	#name : #RBGenericInteractLayer,
	#superclass : #Object,
	#instVars : [
		'refactoring',
		'method',
		'sourceNode'
	],
	#category : #'Refactoring-InteractiveLayer'
}

{ #category : #initialization }
RBGenericInteractLayer class >> method: aMethod class: aClass interval: anInterval [
	"Initialize method and node of this class given:
	aMethod: a string of method name
	aClass: class that owns the given method"
	
	|instance|
	instance := self new.
	instance method:  (instance compiledMethodOf: aMethod from: aClass).
	instance sourceNode: (instance method astForStylingInCalypso bestNodeFor: anInterval).
	instance sourceNode ifNil: [ instance sourceNode: instance method astForStylingInCalypso ].
	^ instance
]

{ #category : #'as yet unclassified' }
RBGenericInteractLayer class >> sourceNode: source method: method [
	^ self new 
		sourceNode: source; 
		method: method .
]

{ #category : #'as yet unclassified' }
RBGenericInteractLayer >> compiledMethodOf: aMethod from: aClass [
	"Return compiled method given a method name (string) and a class"
	
	| index |
	(aClass methods collect: #selector)
		withIndexDo: [ :each :i | 
			each = aMethod asSymbol
				ifTrue: [ index := i ] ].
	^ aClass methods at: index
]

{ #category : #execution }
RBGenericInteractLayer >> execute [
	[
		self executionOfRequirements.
		self executeRefactoring.
		self showChanges 
	] 
	on: RBRefactoringError 
	do: [ :e | UIManager default alert: e messageText ]
]

{ #category : #'as yet unclassified' }
RBGenericInteractLayer >> executeInlineTemp [
	self executeThis: [self inlineTempWithPerform: #primitiveExecute]
]

{ #category : #execution }
RBGenericInteractLayer >> executeRefactoring [
]

{ #category : #'as yet unclassified' }
RBGenericInteractLayer >> executeRefactoringWith: aSymbol [
	"Execute aSymbol refactoring method"
	
	[refactoring perform: aSymbol.
	^ refactoring ] on:RBRefactoringError do: [ :e | e signal]
]

{ #category : #execution }
RBGenericInteractLayer >> executeThis: aBlock [
	[
		self executionOfRequirements.
		aBlock value.
		self showChanges 
	] 
	on: RBRefactoringError 
	do: [ :e | UIManager default alert: e messageText ]
]

{ #category : #'as yet unclassified' }
RBGenericInteractLayer >> executionOfRequirements [
	"If the refactoring needs some requirement like newName or other thing you must
	 do this here"
]

{ #category : #'as yet unclassified' }
RBGenericInteractLayer >> inlineTemp [
	"Return inline temporary refactoring using method and node"
	
	| assignment |
	assignment := sourceNode methodNode assignmentNodes
		detect: [ :each | each variable = sourceNode ].
	^ RBInlineTemporaryRefactoring
		inline: assignment sourceInterval
		from: method selector
		in: method origin
]

{ #category : #'as yet unclassified' }
RBGenericInteractLayer >> inlineTempWithPerform: aSymbol [
	"Method for use a inline temporary refactoring from a playground, 
	this run the aSymbol method of refactoring"

	refactoring := self inlineTemp.
	^ self executeRefactoringWith: aSymbol
]

{ #category : #accessing }
RBGenericInteractLayer >> method [
	^ method
]

{ #category : #accessing }
RBGenericInteractLayer >> method: anObject [
	method := anObject
]

{ #category : #accessing }
RBGenericInteractLayer >> refactoring [
	^ refactoring
]

{ #category : #accessing }
RBGenericInteractLayer >> refactoring: anObject [
	refactoring := anObject
]

{ #category : #'as yet unclassified' }
RBGenericInteractLayer >> showChanges [
	(ChangesBrowserPresenter changes: {refactoring}) open
]

{ #category : #accessing }
RBGenericInteractLayer >> sourceNode [
	^ sourceNode
]

{ #category : #accessing }
RBGenericInteractLayer >> sourceNode: anObject [
	sourceNode := anObject
]
