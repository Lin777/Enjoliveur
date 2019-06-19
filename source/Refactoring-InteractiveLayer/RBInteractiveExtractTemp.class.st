Class {
	#name : #RBInteractiveExtractTemp,
	#superclass : #RBGenericInteractLayer,
	#instVars : [
		'tempName'
	],
	#category : #'Refactoring-InteractiveLayer'
}

{ #category : #'as yet unclassified' }
RBInteractiveExtractTemp >> executeExtractTemp [
	self
		executeThis: [ refactoring := self extractTempWithName: tempName.
			self executeRefactoringWith: #primitiveExecute ]
]

{ #category : #'as yet unclassified' }
RBInteractiveExtractTemp >> executionOfRequirements [
	tempName := UIManager default 
		request: 'New temp name' 
		initialAnswer: ''
		title: 'Extract code to temp variable'.
	tempName isEmptyOrNil ifTrue: [ RBRefactoringError signal ]
]
