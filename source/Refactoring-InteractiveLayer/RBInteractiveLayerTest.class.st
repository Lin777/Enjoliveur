Class {
	#name : #RBInteractiveLayerTest,
	#superclass : #TestCase,
	#instVars : [
		'interactiveLayer'
	],
	#category : #'Refactoring-InteractiveLayer'
}

{ #category : #'as yet unclassified' }
RBInteractiveLayerTest >> createHierarchyTestingClass [
	| newClass2|
	self class compiler 
		evaluate: 'Object subclass: #RBTestingA
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''Refactoring-InteractiveLayer'''.
	
	newClass2 := self class compiler 
		evaluate: 'RBTestingA subclass: #RBTestingB
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''Refactoring-InteractiveLayer'''.
	
	newClass2 compile: 'foo
	^ nil' classified: 'accessing'.
]

{ #category : #'as yet unclassified' }
RBInteractiveLayerTest >> createTestingClass [
	|newClass|
	newClass := self class compiler 
		evaluate: 'Object subclass: #RBTestingRefactoring
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''Refactoring-InteractiveLayer'''.
	
	newClass compile: 'example
	| a b c |
	a := 3.
	b := 5.
	c := a + b.
	c := c + a' classified: 'accessing'.
	
	newClass compile: 'example2
	| a b c |
	a := self getA.
	b := 5.
	c := a + b.
	c := c + a' classified: 'accessing'.
	
	newClass compile: 'example3
	| a b c |
	a := self getA.
	b := 5.
	c := (a + b) + b.
	c := c + a' classified: 'accessing'.
	
	newClass compile: 'getA
	^ 3' classified: 'accessing'.
]

{ #category : #'as yet unclassified' }
RBInteractiveLayerTest >> getTestingClass [
	^ (Smalltalk globals at: #RBTestingRefactoring)
]

{ #category : #'as yet unclassified' }
RBInteractiveLayerTest >> getTestingClass: className [
	^ (Smalltalk globals at: className asSymbol)
]

{ #category : #'as yet unclassified' }
RBInteractiveLayerTest >> removeHierarchyClasses [
	Smalltalk globals removeClassNamed: #RBTestingB.
	
	Smalltalk globals removeClassNamed: #RBTestingA.
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
	self removeHierarchyClasses.
	super tearDown.
]

{ #category : #'as yet unclassified' }
RBInteractiveLayerTest >> testExtractMethod [
	"interactiveLayer extractMethodIn: 'example' withClass: (self getTestingClass)
	 for: (44 to: 49) withName: 'add: a to: b'.
	
	self assert: (interactiveLayer compiledMethodOf: 'example' from: (self getTestingClass) ) sourceCode equals: 'foo
	^ nil'"
]

{ #category : #'as yet unclassified' }
RBInteractiveLayerTest >> testExtractTemp [
	interactiveLayer extractTempIn: 'example3' withClass: (self getTestingClass) 
	for:  (53 to: 59) withTempName: 'd'.
	
	self assert: (interactiveLayer compiledMethodOf: 'example3' from: (self getTestingClass) ) sourceCode equals: 'example3
	| a b c d |
	a := self getA.
	b := 5.
	d := a + b.
	c := d + b.
	c := c + a'
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

{ #category : #'as yet unclassified' }
RBInteractiveLayerTest >> testPushUpMethod [
	self createHierarchyTestingClass .
	interactiveLayer pushUpMethod: 'foo' inClass: (self getTestingClass: 'RBTestingB').
	self assert: (self getTestingClass: 'RBTestingB') methods isEmpty .
	self assert: (self getTestingClass: 'RBTestingA') methods isNotEmpty .
]

{ #category : #'as yet unclassified' }
RBInteractiveLayerTest >> testRenameTemporary [
	interactiveLayer renameTempIn: 'example' withClass: (self getTestingClass) 
	for: (12 to: 12) withName: 'x'.
	
	self assert: (interactiveLayer compiledMethodOf: 'example' from: (self getTestingClass) ) sourceCode equals: 'example
	| x b c |
	x := 3.
	b := 5.
	c := x + b.
	c := c + x'
]
