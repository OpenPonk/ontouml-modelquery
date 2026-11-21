"
I am a utility trait that resolves and retrieves UML elements, associations, and specific OntoUML stereotypes from a model or profile. I provide the foundational lookup logic required for complex model queries.
"
Trait {
	#name : 'TProfileGatherer',
	#category : 'OpenPonk-OntoUML-ModelQuery',
	#package : 'OpenPonk-OntoUML-ModelQuery'
}

{ #category : 'utilities' }
TProfileGatherer classSide >> getStereotype: aElement [

	^ aElement appliedStereotypes detect: [ :stereotype | stereotype isKindOf: OntoUMLElement ] ifNone: [ nil ]
]

{ #category : 'utilities' }
TProfileGatherer classSide >> getStereotypeClass: aElement [
	| stereotype |
	stereotype := self getStereotype: aElement.
	stereotype ifNil: [ ^ nil. ] ifNotNil: [ ^ stereotype class. ].
]
