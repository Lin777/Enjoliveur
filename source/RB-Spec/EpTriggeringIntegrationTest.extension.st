Extension { #name : #EpTriggeringIntegrationTest }

{ #category : #'*RB-Spec-Extensions' }
EpTriggeringIntegrationTest >> changesBrowserOpenedWindows [

	^ ChangesBrowserPresenter allSubInstances reject: [ :each | each window isClosed ]
]
