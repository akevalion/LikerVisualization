"
A basic liker visualization
"
Class {
	#name : #RSLikerVisualization,
	#superclass : #RSAbstractContainerBuilder,
	#instVars : [
		'fileName',
		'headers',
		'data',
		'scale',
		'sums'
	],
	#category : #'Roassal3-Liker'
}

{ #category : #hooks }
RSLikerVisualization >> answersData [
	| total doNotKnow |
	total := headers collect: [ :h | | d |
		d := data at: h.
		(d keys 
			select: [ :k | k isNotEmpty ]
			thenCollect: [ :k | (d at: k) ]) sum ].
	doNotKnow := headers collect: [ :h | | d |
		d := data at: h.
		d at: 'Do not know' ifAbsent: [ 0 ] ].
	^ OrderedDictionary new
		at: 'Answered' put: total - doNotKnow;
		at: 'Do not know' put: doNotKnow;
		yourself.
]

{ #category : #'accessing - defaults' }
RSLikerVisualization >> defaultContainer [
	^ RSCanvas new @ RSCanvasController
]

{ #category : #examples }
RSLikerVisualization >> example01 [
	<script: 'self new example01 open
		setLabel: ''Liker Chart'';
		extent: 900@700;
		position: 100@100'>
	self
		fileName: '.\pharo-local\iceberg\LikerVisualization\survey_when_example.csv';
		scale: #('Never'
	     'Sometimes'
	     'Regularly'
	     'Often'
	     'Always').
	self build.
	^ self canvas.
		
]

{ #category : #examples }
RSLikerVisualization >> example02 [
	<script: 'self new example02 open
		setLabel: ''Liker Chart'';
		extent: 900@700;
		position: 100@100'>
	self
		fileName: '.\pharo-local\iceberg\LikerVisualization\survey_importance.csv';
		scale: #('No importance'
	     'Little importance'
	     'Moderately important'
	     'Rather important'
	     'Very important').
	self build.
	^ self canvas.
		
]

{ #category : #accessing }
RSLikerVisualization >> fileName: aString [
	fileName := aString
]

{ #category : #colors }
RSLikerVisualization >> mainColorPalette [
	^ NSScale ordinal 
		range: #('b22222' 'f08080' 'dcdcdc' '6495ed' '00008b')
]

{ #category : #hooks }
RSLikerVisualization >> prepareData [
	| string lines |
	string := fileName asFileReference contents.

	lines := string lines collect: [:line | line splitOn: ','].

	headers := lines first.
	data := OrderedDictionary new.

	headers do: [ :h | data at: h put: Dictionary new].
	lines allButFirst doWithIndex: [ :words :index | 
		words with: headers do: [ :word :h | | dic |
			dic := data at: h.
			dic at: word put: (dic at: word ifAbsent: [ 0 ])+1
		 ] ].
	headers := headers reversed.
	"default value 0"
	headers do: [ :h | scale do: [ :s | (data at: h) at: s ifAbsentPut: [ 0 ] ] ].

]

{ #category : #hooks }
RSLikerVisualization >> prepareSums [
	
	sums := headers collect: [ :h |
	((1 to: scale size /2) collect: [ :i | (data at: h) at: (scale at: i)]) sum * -1 
		- (scale size even 
			ifTrue: [ 0 ]
			ifFalse: [ ((data at: h) at: (scale at: (scale size // 2 + 1)))/2 ]) ].
]

{ #category : #hooks }
RSLikerVisualization >> renderChartIn: aCanvas [
	| shape center chart |
	chart := RSChart new.
	chart container: aCanvas.
	chart extent: 500@220.
	chart padding: 10.
	center := sums min * -1.
	chart addDecoration: (RSXMarkerDecoration new value: center).
	sums := sums + center.
	chart colors: self mainColorPalette.
	
	scale do: [ :s | | widths |
		widths := headers collect: [ :h | (data at: h) at: s ].
		(chart barWidths: widths)
			left: sums;
			barSize: 20.
		sums := sums + widths.
	 ].
	chart addDecoration: (RSHorizontalLikerTick new 
		numberOfTicks: 10;
		color: Color black;
		center: center;
		yourself).
	(chart xlabel: 'Number of Responses') baseShape
		fontSize: 15;
		color: Color black.

	chart addDecoration: (RSVerticalTick new fromNames: headers; fontSize: 15; color: Color black).

	chart build.
	shape := chart decorations first shape.
	shape border color: Color black; joinMiter.
	self renderLegendIn: aCanvas chart: chart labels: scale gapSize: 15.
]

{ #category : #hooks }
RSLikerVisualization >> renderDoNotKnowChartIn: aCanvas [
	| c comp answers left legendShape |
	answers := self answersData.
	comp := RSComposite new.
	c := RSChart new.
	c extent: 100@ 220.
	c container: comp.
	c padding: 10.
	c colors: self secondColorPalette.
	left := Array new: (answers at: answers keys anyOne) size withAll: 0.
	answers keysAndValuesDo: [ :k :list |
		(c barWidths: list)
			barSize: 20;
			left: left.
		left := left + list.
		 ].
	
	c addDecoration: (RSHorizontalTick new 
		numberOfTicks: 5;
		in: [ :tick | tick configuration fontSize: 12 ];
		color: Color black;
		integer).
	c build.
	c decorations first shape border color: Color black; joinMiter.

	legendShape := self renderLegendIn: comp chart: c labels: answers keys gapSize: 5.
	RSVerticalLineLayout new gapSize: 25; on: { c shapes. legendShape }.
	comp adjustToChildren.
	aCanvas add: comp.
	RSHorizontalLineLayout on: { aCanvas shapes. comp }.
]

{ #category : #hooks }
RSLikerVisualization >> renderIn: aCanvas [
	self prepareData.
	self prepareSums.
	self renderChartIn: aCanvas.
	self renderDoNotKnowChartIn: aCanvas.
]

{ #category : #hooks }
RSLikerVisualization >> renderLegendIn: aCanvas chart: aChart labels: labels gapSize: aNumber [
	| b res |
	b := RSLegend new.
	b defaultLabel color: Color black.
	b container: aCanvas.
	b layout grid lineItemsCount: 3; gapSize: aNumber.
	b location offset: 0@20.
	labels with: aChart plots do: [ :s :plot | 
		b text: s withBoxColor: plot computeColor].
	res := nil.
	b legendDo: [ :l | 
		res := l.
		l 
			border: RSBorder new;
			color: (Color white alpha: 0.8);
			padding: 10. ].
	b build.
	^ res
]

{ #category : #accessing }
RSLikerVisualization >> scale: aCollection [
	scale := aCollection
]

{ #category : #colors }
RSLikerVisualization >> secondColorPalette [
	^ NSScale ordinal
		range: #('358f40' 'ff7f27')
]
