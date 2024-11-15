Class {
	#name : 'BaselineOfOpenPonkOntoUMLModelQuery',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfOpenPonkOntoUMLModelQuery',
	#package : 'BaselineOfOpenPonkOntoUMLModelQuery'
}

{ #category : 'baselines' }
BaselineOfOpenPonkOntoUMLModelQuery >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				baseline: 'OpenPonk-OntoUML-Profile'
				with: [ spec
						className: 'BaselineOfOpenPonkOntoUMLProfile';
						repository: 'github://openponk/ontouml-profile';
						loads: 'plugin' ].
			spec
				project: 'OpenPonkOntoUMLProfile'
				copyFrom: 'OpenPonk-OntoUML-Profile'
				with: [ spec loads: 'default' ].
			spec package: 'OpenPonk-OntoUML-ModelQuery'.
			spec
				group: 'plugin'
				with: #('OpenPonk-OntoUML-Profile' 'OpenPonk-OntoUML-ModelQuery').
			spec group: 'default' with: #(OpenPonkOntoUMLProfile 'OpenPonk-OntoUML-ModelQuery') ]
]
