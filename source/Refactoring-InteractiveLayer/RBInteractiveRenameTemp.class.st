Class {
	#name : #RBInteractiveRenameTemp,
	#superclass : #RBGenericInteractLayer,
	#instVars : [
		'newName'
	],
	#category : #'Refactoring-InteractiveLayer'
}

{ #category : #'as yet unclassified' }
RBInteractiveRenameTemp >> executionOfRequirements [
	newName := UIManager default 
		request: 'New name of the variable' 
		initialAnswer: sourceNode name
		title: 'Rename a temp variable'.
	newName isEmptyOrNil | (newName = sourceNode name) ifTrue: [ RBRefactoringError signal ]
]
