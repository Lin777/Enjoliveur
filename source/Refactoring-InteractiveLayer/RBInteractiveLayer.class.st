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
RBInteractiveLayer >> extractMethodIn: aMethod withClass: aClass for: anInterval withName: aString [
	self initializeMethod: aMethod class: aClass interval: anInterval .
	self executeRefactoring: (self extractMethodWithName: aString).
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> extractMethodWithName: aString [
	| refactoring selectedInterval |
	selectedInterval := interval ifEmpty: [ node sourceInterval ].
	
	refactoring := RBExtractMethodRefactoring	
		extract: selectedInterval from: method selector in: method origin.
	self setUpOptionToUseExistingMethodDuring: refactoring.
	self setUpOptionToOverrideExistingMethodDuring: refactoring.
	refactoring setOption: #methodName toUse: aString.
	
	^ refactoring
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> extractMethodWithName: aString withPerform: aSymbol [
	| refactoring |
	
	refactoring := self extractMethodWithName: aString.
	
	[refactoring perform: aSymbol.
	^ refactoring ] on:RBRefactoringError do: [ :e | ^ e ]
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> extractTempIn: aMethod withClass: aClass for: anInterval withTempName: tempName [
	self initializeMethod: aMethod class: aClass interval: anInterval .
	self executeRefactoring: (self extractTempWithName: tempName)
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> extractTempWithName: tempName [
	^ RBExtractToTemporaryRefactoring	
		extract: node sourceInterval
		to: tempName
		from: method selector
		in: method origin
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> extractTempWithName: tempName withPerform: aSymbol [
	| refactoring |
	refactoring := self extractMethodWithName: tempName .
	
	[refactoring perform: aSymbol.
	^ refactoring ] on:RBRefactoringError do: [ :e | ^ e ]
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
	^ RBInlineMethodRefactoring	
		inline: node sourceInterval
		inMethod: method selector
		forClass: method origin.
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> inlineMethodIn: aMethod withClass: aClass for: anInterval [
	self initializeMethod: aMethod class: aClass interval: anInterval .
	self executeRefactoring: (self inlineMethod)
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> inlineMethodWithPerform: aSymbol [
	| refactoring |
	refactoring := self inlineMethod.

	[refactoring perform: aSymbol.
	^ refactoring ] on:RBRefactoringError do: [ :e | ^ e ]
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> inlineTemp [
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
	self initializeMethod: aMethod class: aClass interval: anInterval .
	self executeRefactoring: (self inlineTemp)
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> inlineTempWithPerform: aSymbol [
	| refactoring |
	refactoring := self inlineTemp.
	
	[refactoring perform: aSymbol.
	^ refactoring ] on:RBRefactoringError do: [ :e | ^ e ]
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
	^ RBPullUpMethodRefactoring 
		pullUp: {method selector} 
		from: method origin
	
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> pushUpMethod: aMethod inClass: aClass [
	self initializeMethod: aMethod class: aClass interval: nil .
	self executeRefactoring: (self pushUpMethod)
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> pushUpMethodWithPerform: aSymbol [ 
	| refactoring |
	refactoring := self pushUpMethod.

	[refactoring perform: aSymbol.
	^ refactoring ] on:RBRefactoringError do: [ :e | ^ e ]
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> renameTempIn: aMethod withClass: aClass for: anInterval withName: aString [
	self initializeMethod: aMethod class: aClass interval: anInterval .
	self executeRefactoring: (self renameTempWithName: aString)
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> renameTempWithName: aString [
	 ^ RBRenameTemporaryRefactoring	
		renameTemporaryFrom: node sourceInterval
		to: aString
		in: method origin
		selector: method selector
]

{ #category : #'as yet unclassified' }
RBInteractiveLayer >> renameTempWithName: newName withPerform: aSymbol [
	| refactoring |
	refactoring := self renameTempWithName: newName.
	
	[refactoring perform: aSymbol.
	^ refactoring ] on:RBRefactoringError do: [ :e | ^ e ]
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
