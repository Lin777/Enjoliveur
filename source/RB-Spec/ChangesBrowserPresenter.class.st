Class {
	#name : #ChangesBrowserPresenter,
	#superclass : #ComposablePresenter,
	#instVars : [
		'textArea',
		'changesTree',
		'changes',
		'selectedChanges'
	],
	#category : #'RB-Spec'
}

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter class >> buildShortcutsOn: aBuilder [
	<keymap>

	(aBuilder shortcut: #close)
		category: #ChangesBrowserGlobalShortcuts
		default: PharoShortcuts current cancelShortcut
		do: [ :target | target cancel ]
		description: 'Close this dialog'.
		
	(aBuilder shortcut: #accept)
		category: #ChangesBrowserGlobalShortcuts
		default: PharoShortcuts current acceptShortcut
		do: [ :target | target accept ]
		description: 'Accept the proposed changes'.
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter class >> changes: aCollection [

	^ self new
		changes: aCollection;
		yourself
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter class >> defaultSpec [
	<spec: #default>
	
	^ SpecBoxLayout newVertical add: (SpecBoxLayout newHorizontal
				add: #changesTree; yourself);
				add: #textArea;
				yourself 
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter class >> title [

	^ 'Changes Browser'
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> accept [
	self okToChange
		ifFalse: [ ^ self ].
	[ self pickedChanges do: 
		[ :change | RBRefactoryChangeManager instance performChange: change ] 
	] asJob
		title: 'Refactoring';
		run.
	self window delete
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> asEpiceaEvent [
	self flag: #pharoTodo.	"This is a workaround for a problem found by RewriteTool"
	(changes allSatisfy: [ :each | each respondsTo: #asEpiceaEvent ]) ifFalse: [ ^ EpCompositeRefactoring withAll: #() ].

	^ changes size > 1 ifTrue: [ EpCompositeRefactoring withAll: changes ] ifFalse: [ changes anyOne asEpiceaEvent ]
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> buildDiffFor: aChange [
	textArea 
		leftText: aChange oldVersionTextToDisplay;
		rightText: aChange textToDisplay
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> cancel [
	self window delete
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> changes [
	^ changes
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> changes: aCollection [
	changes := aCollection.
	self updateChanges
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> changesTree [
	^ changesTree
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> initializeChangesTree [
	changesTree addColumn:
		((CheckBoxTableColumn title: ' ' evaluated: [ :class | selectedChanges includes: class ])
				onActivation: [ :class | selectedChanges add: class.
					self buildDiffFor: class ];
				onDesactivation: [ :class | selectedChanges remove: class ];
				width: 20;
				yourself);
			addColumn:  (StringTableColumn title: 'Name' evaluated: #name);
			beResizable.
	self whenBuiltDo: [ selectedChanges := changesTree items ]
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> initializePresenter [
	changesTree
		whenSelectionChangedDo:
			[ :item | item ifNotNil: [ self buildDiffFor: 
				(item widget items at: (item selectedIndex))] ]
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> initializeTextArea [
	textArea 
		enabled: false;
		"make sure we can cycle over the text field"
		bindKeyCombination: Character tab toAction: [ self giveFocusToNextFrom: textArea ];
		bindKeyCombination: Character tab shift toAction: [ self giveFocusToPreviousFrom: textArea ].
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> initializeWidgets [
	selectedChanges := OrderedCollection new.
	changesTree := self newTable.
	textArea := self newDiff.
	
	self initializeChangesTree.
	self setFocus.
	self
		bindKeyCombination: PharoShortcuts current acceptShortcut toAction: [ self accept ];
		bindKeyCombination: Character escape toAction: [ self cancel ]
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> isEpiceaInterestingJobOwner [

	^ true
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> open [
	^ self openDialogWithSpec
		okAction: [ self accept ];
		cancelAction: [ self cancel ];
		yourself
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> pickedChanges [
	^ changesTree items select: [ :i | selectedChanges includes: i ]
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> setFocus [
	self focusOrder
		add: changesTree;
		add: textArea;
		yourself
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> setShortcuts [
	self changesTree attachKeymapCategory: #ChangesBrowserGlobalShortcuts targetting: self
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> textArea [
	^ textArea
]

{ #category : #'as yet unclassified' }
ChangesBrowserPresenter >> updateChanges [
	| aCompositeChange |
	aCompositeChange := RBRefactoryChangeManager changeFactory
		compositeRefactoryChange.
	changes do: [ :each | aCompositeChange addChange: each ].
	"Later we could filter the shown changes depending on the selected scope"
	
	changesTree items: (aCompositeChange whatToDisplayIn: self).
]
