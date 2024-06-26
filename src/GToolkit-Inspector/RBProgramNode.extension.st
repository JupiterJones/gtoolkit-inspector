Extension { #name : #RBProgramNode }

{ #category : #'*GToolkit-Inspector' }
RBProgramNode >> gtPropertiesFor: aView [
	<gtView>
	properties ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'Properties';
		priority: 10;
		items: [ properties 
			ifNil: #() 
			ifNotNil: [ :aDictionary |
				aDictionary associations ] ];
		column: 'Key' text: #key;
		column: 'Value' text: #value weight: 3;
		column: 'Type' text: [ :anAssoc | anAssoc value class ] weight: 2;
		send: #value
]

{ #category : #'*GToolkit-Inspector' }
RBProgramNode >> gtSourceCodeFor: aView [
	<gtView>
	self methodNode ifNil: [ ^ aView empty ].
	^ aView explicit
		title: 'Source code';
		actionButtonIcon: BrGlamorousVectorIcons browse
			tooltip: 'Browse'
			action: [ :aButton | self methodNode compiledMethod gtBrowseFrom: aButton ];
		stencil: [ ((self methodNode compilationContext
				ifNil: [ (GtPharoMethodCoder forNewMethod: Object)
						sourceCode: (GtCoderExplicitTextSource new text: self methodNode formattedCode) ]
				ifNotNil: [ GtPharoMethodCoder forMethod: self methodNode compiledMethod ])
				highlighter: (GtRBPatternHighlighter new ast: self);
				asExpandedOnlyElement) vFitContentLimited ]
]

{ #category : #'*GToolkit-Inspector' }
RBProgramNode >> gtTreeFor: aView [
	<gtView> 
	^ aView tree
		title: 'Tree';
		priority: 60;
		items: [ { self } ];
		children: #children;
		expandAll
]

{ #category : #'*GToolkit-Inspector' }
RBProgramNode >> gtVisualTreeFor: aView [
	<gtView>
	
	| wrapperFactory |
	wrapperFactory := RBNodeWrapperFactory new.
	^ (aView mondrian)
		title: 'Map';
		priority: 60;
		painting:
				[ :view | 
					(view nodes)
						shape:
								[ :each | 
									| textElement text |
									text := (each printString truncateTo: 30) asRopedText.
									textElement := BlTextElement new.
									textElement text: text.
									textElement
										when: BlClickEvent
										do:
											[ :e | 
											textElement phlow spawnObject: each node.
											e consumed: true ].
									textElement ];
						with: ((self withDeepCollect: #children) collect: [ :each | wrapperFactory wrapperFor: each ]).
					view edges connectFrom: #parent.
					view layout tree ]
]

{ #category : #'*GToolkit-Inspector' }
RBProgramNode >> gtWithAllChildren [
	| children |
	children := OrderedCollection with: self.
	self nodesDo: [ :each | children addLast: each ].
	^ children
]
