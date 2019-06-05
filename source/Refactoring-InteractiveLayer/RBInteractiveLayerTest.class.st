Class {
	#name : #RBInteractiveLayerTest,
	#superclass : #TestCase,
	#instVars : [
		'interactiveLayer'
	],
	#category : #'Refactoring-InteractiveLayer'
}

{ #category : #'as yet unclassified' }
RBInteractiveLayerTest >> createTestingClass [
	self class compiler 
		evaluate: 'Object subclass: #RBTestingRefactoring
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''Refactoring-InteractiveLayer'''.
	
	self getTestingClass
		compile: 'example
	| a b c |
	a := 3.
	b := 5.
	c := a + b.
	c := c + a' classified: 'accessing'.
	
	self getTestingClass
		compile: 'example2
	| a b c |
	a := self getA.
	b := 5.
	c := a + b.
	c := c + a' classified: 'accessing'.
	
	self getTestingClass
		compile: 'getA
	^ 3' classified: 'accessing'.
]

{ #category : #'as yet unclassified' }
RBInteractiveLayerTest >> getTestingClass [
	^ (Smalltalk globals at: #RBTestingRefactoring)
]

{ #category : #'as yet unclassified' }
RBInteractiveLayerTest >> removeTestingClass [
	Smalltalk globals removeClassNamed: #RBTestingRefactoring.
]

{ #category : #'as yet unclassified' }
RBInteractiveLayerTest >> setUp [
	super setUp.
	self createTestingClass .
	interactiveLayer := RBInteractiveLayer new 
]

{ #category : #'as yet unclassified' }
RBInteractiveLayerTest >> tearDown [
	self removeTestingClass.
	super tearDown.
]

{ #category : #'as yet unclassified' }
RBInteractiveLayerTest >> testExtractMethod [
	
]

{ #category : #'as yet unclassified' }
RBInteractiveLayerTest >> testInlineMethod [
	interactiveLayer inlineMethodIn: 'example2' withClass: (self getTestingClass)
	 for: (27 to: 36).
	self assert: (interactiveLayer compiledMethodOf: 'example2' from: (self getTestingClass) ) sourceCode equals: 'example2
	| a b c |
	a := 3.
	b := 5.
	c := a + b.
	c := c + a'
]

{ #category : #'as yet unclassified' }
RBInteractiveLayerTest >> testInlineTemp [
	interactiveLayer inlineTempIn: 'example' withClass: (self getTestingClass)
	 for: (44 to: 44).
	self assert: (interactiveLayer compiledMethodOf: 'example' from: (self getTestingClass) ) sourceCode equals: 'example
	| b c |
	b := 5.
	c := 3 + b.
	c := c + 3'
]
