Class {
	#name : #RBInteractiveLayer,
	#superclass : #Object,
	#instVars : [
		'class',
		'method',
		'interval',
		'node'
	],
	#category : #'Refactoring-InteractiveLayer'
}

{ #category : #accessing }
RBInteractiveLayer >> class1 [
	^ class
]

{ #category : #accessing }
RBInteractiveLayer >> class: anObject [
	class := anObject
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> compiledMethodOf: aMethod from: aClass [
	| index |
	(aClass methods collect: #selector)
		withIndexDo: [ :each :i | 
			each = aMethod asSymbol
				ifTrue: [ index := i ] ].
	^ aClass methods at: index
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> executeRefactoring: refactoring [
	"NautilusRefactoring new refactoringOptions: refactoring."
	[ refactoring execute ] on: RBRefactoringError do: [ :e | 
	UIManager default alert: e messageText ].
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> extractMethod [
	| refactoring dialog selectedInterval |
	selectedInterval := interval ifEmpty: [ node sourceInterval ].
	
	refactoring := RBExtractMethodRefactoring	
		extract: selectedInterval from: method selector in: method origin.
	self setUpOptionToUseExistingMethodDuring: refactoring.
	self setUpOptionToOverrideExistingMethodDuring: refactoring.
	refactoring setOption: #methodName toUse:  [ :ref :methodName |
		dialog := SycMethodNameEditor openOn: methodName.
		dialog cancelled ifTrue: [  CmdCommandAborted signal ].
		methodName].
	
	self executeRefactoring: refactoring.
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> extractMethodIn: aMethod withClass: aClass for: anInterval [
	self initializeMethod: aMethod class: aClass interval: anInterval .
	self extractMethod.
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> initializeMethod: aMethod class: aClass interval: anInterval [
	interval := anInterval.
	method := self compiledMethodOf: aMethod from: aClass.
	node := method astForStylingInCalypso bestNodeFor: anInterval.
	node ifNil: [ node := method astForStylingInCalypso ]
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> inlineMethod [
	| refactoring |
	refactoring := RBInlineMethodRefactoring	
		inline: node sourceInterval
		inMethod: method selector
		forClass: method origin.

	self executeRefactoring: refactoring.
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> inlineMethodIn: aMethod withClass: aClass for: anInterval [
	self initializeMethod: aMethod class: aClass interval: anInterval .
	self inlineMethod.
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> inlineTemp [
	| assignment refactoring |
	assignment := node methodNode assignmentNodes
		detect: [ :each | each variable = node ].
	refactoring := RBInlineTemporaryRefactoring
		inline: assignment sourceInterval
		from: method selector
		in: method origin.
	
	self executeRefactoring: refactoring.
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> inlineTempIn: aMethod withClass: aClass for: anInterval [
	self initializeMethod: aMethod class: aClass interval: anInterval .
	self inlineTemp.
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
