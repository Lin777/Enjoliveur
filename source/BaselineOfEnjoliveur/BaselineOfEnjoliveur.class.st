Class {
	#name : #BaselineOfEnjoliveur,
	#superclass : #BaselineOf,
	#category : #BaselineOfEnjoliveur
}

{ #category : #baselines }
BaselineOfEnjoliveur >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			self setUpDependencies: spec.
			spec package: 'RB-Spec';
			package: 'RB-Spec-Tests';
			package: 'Refactoring-InteractiveLayer' with: [ spec requires: 'SystemCommands' ]]
]

{ #category : #baselines }
BaselineOfEnjoliveur >> setUpDependencies: spec [
	spec	
		baseline: 'SystemCommands'	
		with: [ spec	
				repository: 
				'github://Lin777/SystemCommands:ChangeRefactorCommands/repository' ].

]
