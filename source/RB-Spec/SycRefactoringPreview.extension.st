Extension { #name : #SycRefactoringPreview }

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> accept [
	self okToChange
		ifFalse: [ ^ self ].
	[ self pickedChanges do: [ :change | RBRefactoryChangeManager instance performChange: change ] ] asJob
		title: 'Refactoring';
		run.
	self window delete
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> activeRBEnvironment [
	
	^self activeScope asRBEnvironment
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> activeScope [
	^scopeDropList selectedItem
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> asEpiceaEvent [

	self flag: #todo. "This is a workaround for a problem found by RewriteTool"
	(changes allSatisfy: [ :each | each respondsTo: #asEpiceaEvent ])
		ifFalse: [ ^ EpCompositeRefactoring withAll: #() ].

	^ changes size > 1
		ifTrue: [ EpCompositeRefactoring withAll: changes ]
		ifFalse: [ changes anyOne asEpiceaEvent ].
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> buildDiffFor: aChange [

	^ aChange
		ifNil: [ '' ]
		ifNotNil: [
			TextDiffBuilder 
				buildDisplayPatchFrom: aChange oldVersionTextToDisplay 
				to: aChange textToDisplay ].
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview class >> buildShortcutsOn: aBuilder [
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
SycRefactoringPreview >> cancel [
	self window delete
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> changes [
	^ changes
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> changes: aCollection [
	changes := aCollection
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> changesTree [
	^ changesTree
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> command [
	^ command
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> command: aCommand [
	command := aCommand
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview class >> defaultSpec [
	<spec>
	^ SpecBoxLayout newVertical 
		add: (SpecBoxLayout newVertical
					add: #changesTree; 
					add: #scopeDropList withConstraints: [ :c | c height: 30 ]; yourself );
		add: #textArea; 
		yourself
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview class >> for: aCommand scopes: scopes [

	^ self new
		command: aCommand;
		scopes: scopes
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> generateChanges [

	| rbEnvironment |
	changes := command asRefactorings.
	rbEnvironment := self activeRBEnvironment.
	changes do: [ :each | 
		each model environment: rbEnvironment.
		each primitiveExecute ]
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> initializeChangesTree [
	changesTree
		beCheckList;
		removeOnlyLastSelected: true;
		autoMultiSelection: true;
		rootNodeHolder: [ :item | 
					TreeNodeModel new
						content: item;
						hasContentToShow: true;
						children: [ changesTree childrenFor: item ] ];
		displayBlock: [ :item | item nameToDisplay ].
	self whenBuiltDo: [ changesTree selectAll ]
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> initializePresenter [
	changesTree
		whenHighlightedItemChangedDo:
			[ :item | item ifNotNil: [ textArea text: (self buildDiffFor: item content) ] ]
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> initializeScopeDropList [
	scopeDropList
		displayBlock: [ :scope | scope description capitalized ];
		whenSelectedItemChangedDo: [ :scope | scope ifNotNil: [ self updateChanges ] ]
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> initializeTextArea [
	textArea 
		enabled: false;
		"make sure we can cycle over the text field"
		bindKeyCombination: Character tab toAction: [ self giveFocusToNextFrom: textArea ];
		bindKeyCombination: Character tab shift toAction: [ self giveFocusToPreviousFrom: textArea ].
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> initializeWidgets [

	changesTree := self newTree.
	textArea := self newCode.
	scopeDropList := self newDropList.
	
	self initializeChangesTree.
	self initializeTextArea.
	self initializeScopeDropList.
	self setFocus.
	self
		bindKeyCombination: PharoShortcuts current acceptShortcut toAction: [ self accept ];
		bindKeyCombination: Character escape toAction: [ self cancel ]
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> isEpiceaInterestingJobOwner [

	^ true
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> open [
	^ self openDialogWithSpec
		okAction: [ self accept ];
		cancelAction: [ self cancel ];
		yourself
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> pickedChanges [
	| selectedItems |
	selectedItems := changesTree selectedItems collect: #content.
	^ changesTree roots select: [ :i | selectedItems includes: i ]
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> scopeDropList [
	^ scopeDropList
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> scopes [
	^ scopes
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> scopes: anObject [
	scopes := anObject.
	scopeDropList items: scopes "It also sets up first item as selection"
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> setFocus [
	self focusOrder
		add: changesTree;
		add: textArea;
		yourself
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> setShortcuts [
	self changesTree attachKeymapCategory: #ChangesBrowserGlobalShortcuts targetting: self
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> textArea [
	^ textArea
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview class >> title [
	^ 'Refactoring changes'
]

{ #category : #'*RB-Spec' }
SycRefactoringPreview >> updateChanges [
	| aCompositeChange |
	self generateChanges.
	aCompositeChange := RBCompositeRefactoryChange new.
	changes do: [:each | aCompositeChange addChange: each ].
	
	changesTree roots: (aCompositeChange whatToDisplayIn: self).
	changesTree selectAll
]
