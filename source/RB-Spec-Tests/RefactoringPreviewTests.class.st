Class {
	#name : #RefactoringPreviewTests,
	#superclass : #TestCase,
	#instVars : [
		'preview'
	],
	#category : #'RB-Spec-Tests'
}

{ #category : #running }
RefactoringPreviewTests >> setUp [
	super setUp.
	preview := SycRefactoringPreview new
]

{ #category : #tests }
RefactoringPreviewTests >> testChanges [
	| aCollection |
	aCollection := {RBRefactoryChange new}.
	preview changes: aCollection.
	self assert: preview changes equals: aCollection
]

{ #category : #tests }
RefactoringPreviewTests >> testInitializeWidgets [
	self assert: preview changesTree isNotNil.
	self assert: preview textArea isNotNil.
	self
		assertCollection: preview focusOrder
		equals:
			{preview changesTree.
			preview textArea} asOrderedCollection
]

{ #category : #tests }
RefactoringPreviewTests >> testPickedChanges [
	self assertEmpty: preview pickedChanges
]
