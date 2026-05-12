class_name Month
extends RefCounted


## All dates of this week.
## [br][br]
## [b]Note[/b]: Read-only variable.
var weeks: Array[Week] = []:
	get: return _weeks
	set(d): push_error("Can't modify a read-only property.")

var _weeks: Array[Week] = []
