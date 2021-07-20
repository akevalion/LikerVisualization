"
This custom tick is used to define the mirrow visualization
"
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
	| ticksData delta |
	ticksData := niceLabel min to: niceLabel max by: niceLabel step.
	delta := ticksData size even ifTrue: [ 0 ] ifFalse: [ 1 ].
	^ ticksData + center  - (ticksData at: (ticksData size // 2) + delta)
]
