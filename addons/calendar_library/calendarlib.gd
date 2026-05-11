class_name Calendarlib
extends RefCounted

const _POSIX_PLACEHOLDERS = "(%F|%Y|%y|%m|%B|%b|%-b|%d|%-d|%-m|%-y|%j|%-j|%A|%a|%-a|%u|%w)"

## Rule to how to decide the week number.
## [br][br]
## For example, the following week is the 1º week of the year or 53º week of the previous year?
## [codeblock]
## January
## | M  | T  | W  | T  | F  | S  | S  |
## | 28 | 29 | 30 | 01 | 02 | 03 | 04 |
## [/codeblock]
enum WeekNumberSystem {
	## Follow ISO 8601, where the first week of the year
	## must contain at least 4 days from the new year.
	FOUR_DAY,
	## Tradional, where the first week of the year is always
	## the one containing January 1.
	TRADITIONAL,
}

# Regex used for getting placeholder combinations in get_date_formatted().
static var _posix_regex = RegEx.new()


static func _static_init() -> void:
	_posix_regex.compile(_POSIX_PLACEHOLDERS)
