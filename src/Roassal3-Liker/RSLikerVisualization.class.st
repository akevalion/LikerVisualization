Class {
	#name : #RSLikerVisualization,
	#superclass : #RSAbstractContainerBuilder,
	#instVars : [
		'fileName',
		'headers',
		'data',
		'scale',
		'sums',
		'chart'
	],
	#category : #'Roassal3-Liker'
}

{ #category : #'as yet unclassified' }
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

{ #category : #accessing }
RSLikerVisualization >> fileName: aString [
	fileName := aString
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
	| shape center |
	chart := RSChart new.
	chart container: aCanvas.
	chart extent: 500@220.
	chart padding: 10.
	center := sums min * -1.
	chart addDecoration: (RSXMarkerDecoration new value: center).
	sums := sums + center.
	
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
]

{ #category : #hooks }
RSLikerVisualization >> renderIn: aCanvas [
	self prepareData.
	self prepareSums.
	self renderChartIn: aCanvas.
	self renderLegendIn: aCanvas.
	
]

{ #category : #hooks }
RSLikerVisualization >> renderLegendIn: aCanvas [
	| b |
	b := RSLegend new.
	b defaultLabel color: Color black.
	b container: aCanvas.
	b layout horizontal gapSize: 30.
	b withFrame.
	b location offset: 0@ 20.
	scale with: chart plots do: [ :s :plot | b text: s withBoxColor: plot computeColor].
	b build.
]

{ #category : #accessing }
RSLikerVisualization >> scale: aCollection [
	scale := aCollection
]
