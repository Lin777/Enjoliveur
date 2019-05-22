Class {
	#name : #ChangesBrowserPresenterTest,
	#superclass : #TestCase,
	#instVars : [
		'browser'
	],
	#category : #'RB-Spec-Tests'
}

{ #category : #running }
ChangesBrowserPresenterTest >> setUp [
	super setUp.
	browser := ChangesBrowserPresenter new
]

{ #category : #running }
ChangesBrowserPresenterTest >> testChanges [
	| aCollection |
	aCollection := {RBRefactoryChange new}.
	browser changes: aCollection.
	self assert: browser changes equals: aCollection
]

{ #category : #running }
ChangesBrowserPresenterTest >> testInitializeWidgets [
	self assert: browser changesTree isNotNil.
	self assert: browser textArea isNotNil.
	self
		assertCollection: browser focusOrder
		equals:
			{browser changesTree.
			browser textArea} asOrderedCollection
]

{ #category : #running }
ChangesBrowserPresenterTest >> testPickedChanges [
	self assertEmpty: browser pickedChanges
]
