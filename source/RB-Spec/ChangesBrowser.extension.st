Extension { #name : #ChangesBrowser }

{ #category : #'*RB-Spec' }
ChangesBrowser >> accept [
	self okToChange
		ifFalse: [ ^ self ].
	[ self pickedChanges do: 
		[ :change | RBRefactoryChangeManager instance performChange: change ] 
	] asJob
		title: 'Refactoring';
		run.
	self window delete
]

{ #category : #'*RB-Spec' }
ChangesBrowser >> asEpiceaEvent [
	self flag: #pharoTodo.	"This is a workaround for a problem found by RewriteTool"
	(changes allSatisfy: [ :each | each respondsTo: #asEpiceaEvent ]) ifFalse: [ ^ EpCompositeRefactoring withAll: #() ].

	^ changes size > 1 ifTrue: [ EpCompositeRefactoring withAll: changes ] ifFalse: [ changes anyOne asEpiceaEvent ]
]

{ #category : #'*RB-Spec' }
ChangesBrowser >> buildDiffFor: aChange [
	textArea 
		leftText: aChange oldVersionTextToDisplay;
		rightText: aChange textToDisplay
]

{ #category : #'*RB-Spec' }
ChangesBrowser class >> buildShortcutsOn: aBuilder [
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

{ #category : #'*RB-Spec' }
ChangesBrowser >> cancel [
	self window delete
]

{ #category : #'*RB-Spec' }
ChangesBrowser >> changes [
	^ changes
]

{ #category : #'*RB-Spec' }
ChangesBrowser >> changes: aCollection [
	changes := aCollection.
	self updateChanges
]

{ #category : #'*RB-Spec' }
ChangesBrowser class >> changes: aCollection [

	^ self new
		changes: aCollection;
		yourself
]

{ #category : #'*RB-Spec' }
ChangesBrowser >> changesTree [
	^ changesTree
]

{ #category : #'*RB-Spec' }
ChangesBrowser class >> defaultSpec [
	<spec: #default>
	
	^ SpecBoxLayout newVertical add: (SpecBoxLayout newHorizontal
				add: #changesTree; yourself);
				add: #textArea;
				yourself 
]

{ #category : #'*RB-Spec' }
ChangesBrowser >> initializeChangesTree [
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

{ #category : #'*RB-Spec' }
ChangesBrowser >> initializePresenter [
	changesTree
		whenSelectionChangedDo:
			[ :item | item ifNotNil: [ self buildDiffFor: 
				(item widget items at: (item selectedIndex))] ]
]

{ #category : #'*RB-Spec' }
ChangesBrowser >> initializeTextArea [
	textArea 
		enabled: false;
		"make sure we can cycle over the text field"
		bindKeyCombination: Character tab toAction: [ self giveFocusToNextFrom: textArea ];
		bindKeyCombination: Character tab shift toAction: [ self giveFocusToPreviousFrom: textArea ].
]

{ #category : #'*RB-Spec' }
ChangesBrowser >> initializeWidgets [
	selectedChanges := OrderedCollection new.
	changesTree := self newTable.
	textArea := self newDiff.
	
	self initializeChangesTree.
	self setFocus.
	self
		bindKeyCombination: PharoShortcuts current acceptShortcut toAction: [ self accept ];
		bindKeyCombination: Character escape toAction: [ self cancel ]
]

{ #category : #'*RB-Spec' }
ChangesBrowser >> isEpiceaInterestingJobOwner [

	^ true
]

{ #category : #'*RB-Spec' }
ChangesBrowser >> open [
	^ self openDialogWithSpec
		okAction: [ self accept ];
		cancelAction: [ self cancel ];
		yourself
]

{ #category : #'*RB-Spec' }
ChangesBrowser >> pickedChanges [
	^ changesTree items select: [ :i | selectedChanges includes: i ]
]

{ #category : #'*RB-Spec' }
ChangesBrowser >> setFocus [
	self focusOrder
		add: changesTree;
		add: textArea;
		yourself
]

{ #category : #'*RB-Spec' }
ChangesBrowser >> setShortcuts [
	self changesTree attachKeymapCategory: #ChangesBrowserGlobalShortcuts targetting: self
]

{ #category : #'*RB-Spec' }
ChangesBrowser >> textArea [
	^ textArea
]

{ #category : #'*RB-Spec' }
ChangesBrowser class >> title [

	^ 'Changes Browser'
]

{ #category : #'*RB-Spec' }
ChangesBrowser >> updateChanges [
	| aCompositeChange |
	aCompositeChange := RBRefactoryChangeManager changeFactory
		compositeRefactoryChange.
	changes do: [ :each | aCompositeChange addChange: each ].
	"Later we could filter the shown changes depending on the selected scope"
	
	changesTree items: (aCompositeChange whatToDisplayIn: self).
]
