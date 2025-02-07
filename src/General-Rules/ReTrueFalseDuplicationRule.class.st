"
Checks for ifTrue:ifFalse: blocks that have the same code at the beginning or end. While you might not originally write such code, as it is modified, it is easier to create such code. Instead of having the same code in two places, you should move it outside the blocks.

For example, 
test 
	ifTrue: [self foo. self bar ] 
	ifFalse: [ self foo. self baz ]
 is equivalent to: 

self foo.  
test 
	ifTrue: [ self bar ] 
	ifFalse: [ self baz ]
"
Class {
	#name : 'ReTrueFalseDuplicationRule',
	#superclass : 'ReNodeRewriteRule',
	#category : 'General-Rules-Optimization',
	#package : 'General-Rules',
	#tag : 'Optimization'
}

{ #category : 'accessing' }
ReTrueFalseDuplicationRule class >> group [
	^ 'Optimization'
]

{ #category : 'accessing' }
ReTrueFalseDuplicationRule class >> rationale [
	^ 'Checks for ifTrue:ifFalse: blocks that have the same code at the beginning or end.'
]

{ #category : 'accessing' }
ReTrueFalseDuplicationRule class >> ruleName [
	^ 'Check for same statements at end of ifTrue:ifFalse: blocks'
]

{ #category : 'accessing' }
ReTrueFalseDuplicationRule class >> severity [
	^ #information
]

{ #category : 'accessing' }
ReTrueFalseDuplicationRule class >> uniqueIdentifierName [
	"This number should be unique and should change only when the rule completely change semantics"

	^'EndTrueFalseRule'
]

{ #category : 'hooks' }
ReTrueFalseDuplicationRule >> afterCheck: aNode mappings: mappingDict [

	mappingDict
		at: '`.LastStatement'
		ifPresent: [ :statement |
			^ statement isVariable not ].

	"the first statement is duplicated"
	^ true
]

{ #category : 'initialization' }
ReTrueFalseDuplicationRule >> initialize [
	super initialize.
	self
		"true/false last common"
		replace: '
		`.@PreStatements.
		`@boolExp
			ifTrue: [ | `@trueTemps | `@.TrueStatements. `.LastStatement ]
			ifFalse: [ | `@falseTemps | `@.FalseStatements. `.LastStatement ].
		`.@PostStatements.'
		with: '
		`.@PreStatements.
		`@boolExp
			ifTrue: [ | `@trueTemps | `@.TrueStatements. ]
			ifFalse: [ | `@falseTemps | `@.FalseStatements. ].
		`.LastStatement.
		`.@PostStatements.';

		"false/true last common"
		replace: '
		`.@PreStatements.
		`@boolExp
			ifFalse: [ | `@falseTemps | `@.FalseStatements. `.LastStatement ]
			ifTrue: [ | `@trueTemps | `@.TrueStatements. `.LastStatement ].
		`.@PostStatements.'
		with: '
		`.@PreStatements.
		`@boolExp
			ifFalse: [ | `@falseTemps | `@.FalseStatements. ]
			ifTrue: [ | `@trueTemps | `@.TrueStatements. ].
		`.LastStatement.
		`.@PostStatements.';

		"true/false first common"
		replace: '
		`.@PreStatements.
		`@boolExp
			ifTrue: [ | `@trueTemps | `.FirstStatement. `@.TrueStatements. ]
			ifFalse: [ | `@falseTemps | `.FirstStatement. `@.FalseStatements. ].
		`.@PostStatements.'
		with: '
		`.@PreStatements.
		`.FirstStatement.
		`@boolExp
			ifTrue: [ | `@trueTemps | `@.TrueStatements. ]
			ifFalse: [ | `@falseTemps | `@.FalseStatements. ].
		`.@PostStatements.';

		"false/true first common"
		replace: '
		`.@PreStatements.
		`@boolExp
			ifFalse: [ | `@falseTemps | `.FirstStatement. `@.FalseStatements. ]
			ifTrue: [ | `@trueTemps | `.FirstStatement. `@.TrueStatements. ].
		`.@PostStatements.'
		with: '
		`.@PreStatements.
		`.FirstStatement.
		`@boolExp
			ifFalse: [ | `@falseTemps | `@.FalseStatements. ]
			ifTrue: [ | `@trueTemps | `@.TrueStatements. ].
		`.@PostStatements.'
]
