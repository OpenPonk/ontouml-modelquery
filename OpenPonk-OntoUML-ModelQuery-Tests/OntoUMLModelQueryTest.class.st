"
I am a unit test class verifying the structural query capabilities of OntoUMLModelQuery. I validate the correct extraction of entities, associations, generalization sets, and taxonomic hierarchies based on stereotype filters.
"
Class {
	#name : 'OntoUMLModelQueryTest',
	#superclass : 'TestCase',
	#category : 'OpenPonk-OntoUML-ModelQuery-Tests',
	#package : 'OpenPonk-OntoUML-ModelQuery-Tests'
}

{ #category : 'tests - utility' }
OntoUMLModelQueryTest >> createAssociationFrom: aSource to: aEnd [
	| association|
	association := OPUMLAssociation new.
	OPUMLProperty new
		name: '';
		lowerValue: (OPUMLLiteralInteger new value: 1);
		upperValue: (OPUMLLiteralUnlimitedNatural new value: 1);
		owningAssociation: association;
		type: aSource.
	OPUMLProperty new
		name: '';
		lowerValue: (OPUMLLiteralInteger new value: 1);
		upperValue: (OPUMLLiteralUnlimitedNatural new value: 1);
		owningAssociation: association;
		type: aEnd.
	association memberEnds addAll: association ownedEnds.
	^ association
]

{ #category : 'tests - utility' }
OntoUMLModelQueryTest >> createClass: aName withStereotype: aStereotype [
	| result |
	result := OPUMLClass new.
	result applyStereotype: aStereotype new.
	result name: aName.
	^ result.
]

{ #category : 'tests - utility' }
OntoUMLModelQueryTest >> createGeneralizationFor: aGeneral withSpecific: aSpecific [
	| generalization |
	generalization := OPUMLGeneralization new.
	generalization general: aGeneral;
	specific: aSpecific.
	^ generalization.
]

{ #category : 'tests - utility' }
OntoUMLModelQueryTest >> getClassBlockSorter [
	^ [ :a :b | a name <= b name].
]

{ #category : 'tests - constants' }
OntoUMLModelQueryTest >> getTestAssociation [
	| kind quality association |
	kind := self createClass: 'kind' withStereotype: OntoUMLKind.
	quality := self createClass: 'quality' withStereotype: OntoUMLQuality.
	association := self createAssociationFrom: kind to: quality.
	association applyStereotype: OntoUMLCharacterization new.
	association memberEnds first lowerValue value: 2.
	association memberEnds first upperValue value: '*'.
	^ association.
]

{ #category : 'tests - constants' }
OntoUMLModelQueryTest >> getTestModelForAssociations [

	| kind subkind quality role mediationToKind mediationToSubKind characterization generalization |
	kind := self createClass: 'kind' withStereotype: OntoUMLKind.
	subkind := self createClass: 'subkind' withStereotype: OntoUMLSubKind.
	role := self createClass: 'role' withStereotype: OntoUMLRole.
	quality := self createClass: 'quality' withStereotype: OntoUMLQuality.
	characterization := self createAssociationFrom: kind to: quality.
	characterization applyStereotype: OntoUMLCharacterization new.
	mediationToKind := self createAssociationFrom: kind to: role.
	mediationToKind applyStereotype: OntoUMLMediation new.
	mediationToSubKind := self createAssociationFrom: subkind to: role.
	mediationToSubKind applyStereotype: OntoUMLMediation new.
	generalization := self createGeneralizationFor: kind withSpecific: subkind.
	^ {
		  kind.
		  subkind.
		  quality.
		  role.
		  mediationToKind.
		  mediationToSubKind.
		  characterization.
		  generalization }
]

{ #category : 'tests - constants' }
OntoUMLModelQueryTest >> getTestModelForEntities [
	| elementKind elementSubKindA elementSubKindB elementQuality association generalizationA generalizationB |
	elementKind := self createClass: 'elementKind' withStereotype: OntoUMLKind.
	elementSubKindA := self createClass: 'elementSubKindA' withStereotype: OntoUMLSubKind.
	elementSubKindB := self createClass: 'elementSubKindB' withStereotype: OntoUMLSubKind.
	elementQuality := self createClass: 'elementQuality' withStereotype: OntoUMLQuality.
	association := self createAssociationFrom: elementKind to: elementQuality.
	association applyStereotype: OntoUMLCharacterization new.
	generalizationA := self createGeneralizationFor: elementKind withSpecific: elementSubKindA.
	generalizationB := self createGeneralizationFor: elementKind withSpecific: elementSubKindB.
	^ { elementKind. elementSubKindA. elementSubKindB. elementQuality. association. generalizationA. generalizationB }.
]

{ #category : 'tests - constants' }
OntoUMLModelQueryTest >> getTestModelForGeneralizations [
	| testedChild parent1 parent2 parent3 testedParent sibling outsideElement |
	testedChild := 	self createClass: 'testedChild' withStereotype: OntoUMLRole.
	parent1 := self createClass: 'parent1' withStereotype: OntoUMLRoleMixin.
	parent2 := self createClass: 'parent2' withStereotype: OntoUMLSubKind.
	parent3 := self createClass: 'parent3' withStereotype: OntoUMLSubKind.
	testedParent := self createClass: 'testedParent' withStereotype: OntoUMLKind.
	sibling := 	self createClass: 'sibling' withStereotype: OntoUMLRole.
	outsideElement := self createClass: 'outsideElement' withStereotype: OntoUMLKind.
	
	^ { testedChild. testedParent. parent1. parent2. parent3.  sibling. outsideElement. 
		self createGeneralizationFor: parent1 withSpecific: testedChild.
		self createGeneralizationFor: parent2 withSpecific: testedChild.
		self createGeneralizationFor: parent3 withSpecific: parent2.
		self createGeneralizationFor: parent2 withSpecific: parent3.
		self createGeneralizationFor: testedParent withSpecific: parent2.
		self createGeneralizationFor: parent1 withSpecific: sibling.
		}.
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetAncestorsFor [
	| model result |
	model := self getTestModelForGeneralizations.
	result := ((model select: [ : object | object isKindOf: OPUMLClass. ])
		select: [ :entity | { 'parent1'. 'parent2'. 'parent3'. 'testedParent'. } includes: entity name ])
		sorted: self getClassBlockSorter.
	self assert: ((OntoUMLModelQuery getAncestorsFor: model first) sorted: self getClassBlockSorter) equals: result.
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetAncestorsForInto [
	| model outputAccumulator result |
	model := self getTestModelForGeneralizations.
	result := ((model select: [ : object | object isKindOf: OPUMLClass. ])
		select: [ :entity | { 'parent1'. 'parent2'. 'parent3'. 'testedParent'. } includes: entity name ])
		sorted: self getClassBlockSorter.
	outputAccumulator := Set new.
	OntoUMLModelQuery getAncestorsFor: model first into: outputAccumulator. 
	self assert: (outputAccumulator sorted: self getClassBlockSorter) equals: result.
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetAssociationName [

	| namedSource namedTarget unnamedSource unnamedTarget |
	self assert: (OntoUMLModelQuery getAssociationName: self getTestAssociation) equals: 'kind->quality'.
	namedSource := self createClass: 'Source' withStereotype: OntoUMLKind.
	namedTarget := self createClass: 'Target' withStereotype: OntoUMLQuality.
	unnamedSource := OPUMLClass new.
	unnamedTarget := OPUMLClass new.
	self assert: (OntoUMLModelQuery getAssociationName: (self createAssociationFrom: unnamedSource to: unnamedTarget)) equals: '->'.
	self
		assert: (OntoUMLModelQuery getAssociationName: (self createAssociationFrom: namedSource to: unnamedTarget))
		equals: 'Source->'.
	self
		assert: (OntoUMLModelQuery getAssociationName: (self createAssociationFrom: unnamedSource to: namedTarget))
		equals: '->Target'
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetAssociationsFrom [
	| model result |
	model := self getTestModelForAssociations.
	result := model select: [ :object | object isKindOf: OPUMLAssociation. ].
	self assert: (OntoUMLModelQuery getAssociationsFrom: model) equals: result.
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetAssociationsFromFilterBy [

	| model result |
	model := self getTestModelForAssociations.
	result := OntoUMLModelQuery
		          getAssociationsFrom: model
		          filterBy: [ :association | OntoUMLModelQuery isStereotypeOf: association oclKindOf: 'Mediation' ].
	self assertCollection: result hasSameElements: {
			(model at: 5).
			(model at: 6) }
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetAssociationsFromWithStereotype [

	| model result |
	model := self getTestModelForAssociations.
	result := OntoUMLModelQuery getAssociationsFrom: model withStereotype: OntoUMLMediation.
	self assertCollection: result hasSameElements: {
			(model at: 5).
			(model at: 6) }
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetAssociationsFromWithStereotypeFilterBy [

	| model result |
	model := self getTestModelForAssociations.
	result := OntoUMLModelQuery
		          getAssociationsFrom: model
		          withStereotype: OntoUMLMediation
		          filterBy: [ :association | (OntoUMLModelQuery getSourceFrom: association) name = 'kind' ].
	self assertCollection: result hasSameElements: { (model at: 5) }
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetChildrenOfFrom [
	| model result  |
	model := self getTestModelForGeneralizations.
	result := ((model select: [ : object | object isKindOf: OPUMLClass. ])
		select: [ :entity | { 'parent2'. } includes: entity name])
		sorted: self getClassBlockSorter. 
	self assert: ((OntoUMLModelQuery getChildrenOf: model second from: model)
		sorted: self getClassBlockSorter) asOrderedCollection equals: result asOrderedCollection.
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetDescendantsForFrom [
	| model result |
	model := self getTestModelForGeneralizations.
	result := ((model select: [ : object | object isKindOf: OPUMLClass. ])
		select: [ :entity | { 'parent2'. 'parent3'. 'testedChild'. } includes: entity name ])
		sorted: self getClassBlockSorter.
	self assert: ((OntoUMLModelQuery getDescendantsFor: model second from: model) sorted: self getClassBlockSorter) equals: result.
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetDescendantsForFromInto [
	| model result outputAccumulator |
	model := self getTestModelForGeneralizations.
	result := ((model select: [ : object | object isKindOf: OPUMLClass. ])
		select: [ :entity | { 'parent2'. 'parent3'. 'testedChild'. } includes: entity name ])
		sorted: self getClassBlockSorter.
	outputAccumulator := Set new.
	OntoUMLModelQuery getDescendantsFor: model second from: model into: outputAccumulator.
	self assert: (outputAccumulator sorted: self getClassBlockSorter) equals: result.
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetDescendantsForFromPackagedElements [

	| package rootKind childSubKindA childSubKindB grandChildRole unrelatedKind result accumulator |
	rootKind := self createClass: 'RootKind' withStereotype: OntoUMLKind.
	childSubKindA := self createClass: 'ChildSubKindA' withStereotype: OntoUMLSubKind.
	childSubKindB := self createClass: 'ChildSubKindB' withStereotype: OntoUMLSubKind.
	grandChildRole := self createClass: 'GrandChildRole' withStereotype: OntoUMLRole.
	unrelatedKind := self createClass: 'UnrelatedKind' withStereotype: OntoUMLKind.
	self createGeneralizationFor: rootKind withSpecific: childSubKindA.
	self createGeneralizationFor: childSubKindA withSpecific: childSubKindB.
	self createGeneralizationFor: childSubKindB withSpecific: childSubKindA.
	self createGeneralizationFor: childSubKindA withSpecific: grandChildRole.
	package := OPUMLPackage new.
	package packagedElements addAll: {
			rootKind.
			childSubKindA.
			childSubKindB.
			grandChildRole.
			unrelatedKind }.
	result := OntoUMLModelQuery getDescendantsFor: rootKind from: package packagedElements.
	self assertCollection: result hasSameElements: {
			childSubKindA.
			childSubKindB.
			grandChildRole }.
	accumulator := Set new.
	OntoUMLModelQuery getDescendantsFor: rootKind from: package packagedElements into: accumulator.
	self assertCollection: accumulator hasSameElements: {
			childSubKindA.
			childSubKindB.
			grandChildRole }
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetEntitiesFrom [
	| model result | 
	model := self getTestModelForEntities.
	result := model select: [ :object | object isKindOf: OPUMLClass. ].
	self assert: (OntoUMLModelQuery getEntitiesFrom: model) equals: result. 
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetEntitiesFromFilterBy [

	| model result |
	model := self getTestModelForEntities.
	result := OntoUMLModelQuery getEntitiesFrom: model filterBy: [ :element | element name = 'elementKind' ].
	self assertCollection: result hasSameElements: { model first }
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetEntitiesFromWithStereotype [
	| model result | 
	model := self getTestModelForEntities.
	result := (model select: [ :object | (object isKindOf: OPUMLClass) ])
			select: [ :element | element name = 'elementKind' ].
	self assert: (OntoUMLModelQuery getEntitiesFrom: model withStereotype: OntoUMLKind) equals: result. 
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetEntitiesFromWithStereotypeFilterBy [
	| model result | 
	model := self getTestModelForEntities.
	result := (model select: [ :object | (object isKindOf: OPUMLClass) ])
			select: [ :element | element name = 'elementSubKindA' ].
	self assert: (OntoUMLModelQuery getEntitiesFrom: model
			withStereotype: OntoUMLSubKind 
			filterBy: [ :entity | entity name = 'elementSubKindA' ]) equals: result. 
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetGeneralizationSetsFrom [

	| parent childA childB genA genB genSetA genSetB association model |
	parent := self createClass: 'Parent' withStereotype: OntoUMLKind.
	childA := self createClass: 'ChildA' withStereotype: OntoUMLSubKind.
	childB := self createClass: 'ChildB' withStereotype: OntoUMLSubKind.
	genA := self createGeneralizationFor: parent withSpecific: childA.
	genB := self createGeneralizationFor: parent withSpecific: childB.
	genSetA := OPUMLGeneralizationSet new
		           name: 'SetA';
		           yourself.
	genSetA generalizations add: genA.
	genSetB := OPUMLGeneralizationSet new
		           name: 'SetB';
		           yourself.
	genSetB generalizations add: genB.
	association := self createAssociationFrom: parent to: childA.
	model := {
		         parent.
		         childA.
		         childB.
		         genA.
		         genB.
		         genSetA.
		         genSetB.
		         association }.
	self assertCollection: (OntoUMLModelQuery getGeneralizationSetsFrom: model) hasSameElements: {
			genSetA.
			genSetB }.
	self assertEmpty: (OntoUMLModelQuery getGeneralizationSetsFrom: {
				 parent.
				 childA.
				 association })
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetGeneralizationsFrom [
	| model result  |
	model := self getTestModelForGeneralizations.
	result := model select: [ : object | object isKindOf: OPUMLGeneralization. ].
	self assert: (OntoUMLModelQuery getGeneralizationsFrom: model) equals: result asSet.
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetGeneralizationsFromFilterBy [
	| model result  |
	model := self getTestModelForGeneralizations.
	result := (model select: [ : object | object isKindOf: OPUMLGeneralization. ])
		select: [ :generalization | generalization specific = model first].
	self assert: (OntoUMLModelQuery getGeneralizationsFrom: model filterBy:
		[ :generalization | generalization specific = model first]) equals: result asSet.
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetGeneralizationsWithoutGenSetsFrom [

	| parent childA childB childC genInSetA genInSetB genWithoutSet generalizationSet model |
	parent := self createClass: 'Parent' withStereotype: OntoUMLKind.
	childA := self createClass: 'ChildA' withStereotype: OntoUMLSubKind.
	childB := self createClass: 'ChildB' withStereotype: OntoUMLSubKind.
	childC := self createClass: 'ChildC' withStereotype: OntoUMLSubKind.
	genInSetA := self createGeneralizationFor: parent withSpecific: childA.
	genInSetB := self createGeneralizationFor: parent withSpecific: childB.
	genWithoutSet := self createGeneralizationFor: parent withSpecific: childC.
	generalizationSet := OPUMLGeneralizationSet new.
	generalizationSet generalizations addAll: {
			genInSetA.
			genInSetB }.
	model := {
		         parent.
		         childA.
		         childB.
		         childC.
		         generalizationSet }.
	self assertCollection: (OntoUMLModelQuery getGeneralizationsWithoutGenSetsFrom: model) hasSameElements: { genWithoutSet }
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetParentsOf [
	| model result  |
	model := self getTestModelForGeneralizations.
	result := ((model select: [ : object | object isKindOf: OPUMLClass. ])
		select: [ :entity | { 'parent1'. 'parent2' .} includes: entity name])
		sorted: self getClassBlockSorter. 
	self assert: ((OntoUMLModelQuery getParentsOf: model first)
		sorted: self getClassBlockSorter) equals: result asOrderedCollection.
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetSourceEndFrom [
	| association result |
	association := self getTestAssociation.
	result := association memberEnds first.
	self assert: (OntoUMLModelQuery getSourceEndFrom: association ) equals: result.
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetSourceFrom [
	| association result |
	association := self getTestAssociation.
	result := association memberEnds first type.
	self assert: (OntoUMLModelQuery getSourceFrom: association ) equals: result.
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetStereotype [

	| elementWithStereotype kindStereotype plainElement nonOntoUmlOnlyElement mixedElement roleStereotype |
	elementWithStereotype := OPUMLClass new.
	kindStereotype := OntoUMLKind new.
	elementWithStereotype applyStereotype: kindStereotype.
	plainElement := OPUMLClass new.
	nonOntoUmlOnlyElement := OPUMLClass new.
	nonOntoUmlOnlyElement appliedStereotypes add: OPUMLStereotype new.
	mixedElement := OPUMLClass new.
	mixedElement appliedStereotypes add: OPUMLStereotype new.
	roleStereotype := OntoUMLRole new.
	mixedElement applyStereotype: roleStereotype.
	self assert: (OntoUMLModelQuery getStereotype: elementWithStereotype) identicalTo: kindStereotype.
	self assert: (OntoUMLModelQuery getStereotype: plainElement) equals: nil.
	self assert: (OntoUMLModelQuery getStereotype: nonOntoUmlOnlyElement) equals: nil.
	self assert: (OntoUMLModelQuery getStereotype: mixedElement) identicalTo: roleStereotype
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetStereotypeClass [

	| elementWithStereotype plainElement nonOntoUmlOnlyElement |
	elementWithStereotype := self createClass: 'KindClass' withStereotype: OntoUMLKind.
	plainElement := OPUMLClass new.
	nonOntoUmlOnlyElement := OPUMLClass new.
	nonOntoUmlOnlyElement appliedStereotypes add: OPUMLStereotype new.
	self assert: (OntoUMLModelQuery getStereotypeClass: elementWithStereotype) identicalTo: OntoUMLKind.
	self assert: (OntoUMLModelQuery getStereotypeClass: plainElement) equals: nil.
	self assert: (OntoUMLModelQuery getStereotypeClass: nonOntoUmlOnlyElement) equals: nil
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetTargetEndFrom [
	| association result |
	association := self getTestAssociation.
	result := association memberEnds second.
	self assert: (OntoUMLModelQuery getTargetEndFrom: association ) equals: result.
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testGetTargetFrom [
	| association result |
	association := self getTestAssociation.
	result := association memberEnds second type.
	self assert: (OntoUMLModelQuery getTargetFrom: association ) equals: result.
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testIsOclKindOf [

	| stereotypeKind stereotypeMixin |
	stereotypeKind := OntoUMLKind new.
	stereotypeMixin := OntoUMLMixin new.
	self assert: (OntoUMLModelQuery is: stereotypeKind oclKindOf: 'Sortal') description: 'Kind stereotype must be an OCL Sortal'.
	self assert: (OntoUMLModelQuery is: stereotypeKind oclKindOf: 'Kind') description: 'Kind stereotype must be an OCL Kind'.
	self deny: (OntoUMLModelQuery is: nil oclKindOf: 'Sortal') description: 'Nil stereotype must not satisfy OCL kind check'.
	self deny: (OntoUMLModelQuery is: stereotypeMixin oclKindOf: 'Sortal') description: 'Mixin stereotype must not be an OCL Sortal'
]

{ #category : 'tests' }
OntoUMLModelQueryTest >> testIsStereotypeOfOclKindOf [

	| elementKind elementStereotypeLess elementMixin |
	elementKind := self createClass: 'kind' withStereotype: OntoUMLKind.
	elementStereotypeLess := OPUMLClass new.
	elementMixin := self createClass: 'mixin' withStereotype: OntoUMLMixin.
	self
		assert: (OntoUMLModelQuery isStereotypeOf: elementKind oclKindOf: 'Sortal')
		description: 'Kind class must have a Sortal stereotype'.
	self
		assert: (OntoUMLModelQuery isStereotypeOf: elementKind oclKindOf: 'Kind')
		description: 'Kind class must have a Kind stereotype'.
	self
		deny: (OntoUMLModelQuery isStereotypeOf: elementStereotypeLess oclKindOf: 'Sortal')
		description: 'Class without stereotype must not satisfy OCL kind check'.
	self
		deny: (OntoUMLModelQuery isStereotypeOf: elementMixin oclKindOf: 'Sortal')
		description: 'Mixin class must not have a Sortal stereotype'
]
