Class {
	#name : #Example,
	#superclass : #Object,
	#category : #'Refactoring-InteractiveLayer'
}

{ #category : #examples }
Example >> example [
	| b c |
	b := 5.
	c := 3 + b.
	c := c + 3
]
