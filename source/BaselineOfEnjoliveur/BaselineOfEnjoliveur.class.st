Class {
	#name : #BaselineOfEnjoliveur,
	#superclass : #BaselineOf,
	#category : #BaselineOfEnjoliveur
}

{ #category : #baselines }
BaselineOfEnjoliveur class >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec package: 'RB-Spec';
			package: 'RB-Spec-Tests']
]

{ #category : #baselines }
BaselineOfEnjoliveur >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
			spec
				package: 'RB-Spec';
				package: 'RB-Spec-Tests';
				package: 'RB-Spec-Extensions']
]
