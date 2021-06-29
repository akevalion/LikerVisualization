Class {
	#name : #RSHorizontalLikerTick,
	#superclass : #RSHorizontalTick,
	#instVars : [
		'center'
	],
	#category : #'Roassal3-Liker'
}

{ #category : #accessing }
RSHorizontalLikerTick >> center: aNumber [
	center := aNumber
]

{ #category : #accessing }
RSHorizontalLikerTick >> initialize [
	super initialize.
	self labelConversion: [ :l | (l -center) asInteger abs ].
	self configuration fontSize: 12
]

{ #category : #accessing }
RSHorizontalLikerTick >> ticksData [ 
	| ticksData |
	ticksData := niceLabel min to: niceLabel max by: niceLabel step.
	^ ticksData + center - (ticksData at: (ticksData size // 2) + 1)
]
