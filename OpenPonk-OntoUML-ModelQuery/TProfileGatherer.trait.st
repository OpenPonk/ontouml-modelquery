"
I am a utility trait that resolves and retrieves UML elements, associations, and specific OntoUML stereotypes from a model or profile. I provide the foundational lookup logic required for complex model queries.
"
Trait {
	#name : 'TProfileGatherer',
	#category : 'OpenPonk-OntoUML-ModelQuery',
	#package : 'OpenPonk-OntoUML-ModelQuery'
}

{ #category : 'utilities' }
TProfileGatherer classSide >> getAssociation: aStereotype [
	^ aStereotype base_Association.
]

{ #category : 'utilities' }
TProfileGatherer classSide >> getElement: aStereotype [
	^ aStereotype base_Class.
]

{ #category : 'utilities' }
TProfileGatherer classSide >> getStereotype: aElement [
	| stereotypes |
	stereotypes := aElement appliedStereotypes select: [ :stereotype | stereotype isKindOf: OntoUMLElement ].
	stereotypes isEmpty ifTrue: [ ^ nil ] ifFalse: [ ^ stereotypes at: 1 ].
]

{ #category : 'utilities' }
TProfileGatherer classSide >> getStereotypeClass: aElement [
	| stereotype |
	stereotype := self getStereotype: aElement.
	stereotype ifNil: [ ^ nil. ] ifNotNil: [ ^ stereotype class. ].
]
