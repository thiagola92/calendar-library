class_name Week
extends RefCounted


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

## All dates of this week.
## [br][br]
## [b]Note[/b]: Read-only variable.
var dates: Array[Date]:
	get: return _dates
	set(d): push_error("Can't modify a read-only property.")

var _dates: Array[Date] = []


## Returns a Week object which contains the [param date] and the others days of the same week.
## [br][br]
## Use [param first] to set which weekday defines the start of the week, because different
## places have different starting weekday (e.g. US start with Sunday and Europe start with Monday).
## [br][br]
## The same date can get different weeks depending of [param first]. For example, May 1º (2026):
## [codeblock]
## first == Monday
## | M  | T  | W  | T* | F  | S  | S  |
## | 28 | 29 | 30 | 01 | 02 | 03 | 04 |
##
## first == Thursday
## | T* | F  | S  | S  | M  | T  | W  |
## | 01 | 02 | 03 | 04 | 05 | 06 | 07 |
## 
## first == Sunday
## | S  | M  | T  | W  | T* | F  | S  |
## | 27 | 28 | 29 | 30 | 01 | 02 | 03 |
## [/codeblock]
static func get_week(date: Date, first: Time.Weekday = Time.WEEKDAY_SUNDAY) -> Week:
	if date == null:
		push_error("Date can't be null")
		return null
	
	var week := Week.new()
	var current_date := date.duplicate()
	var weekday: Time.Weekday = date.get_weekday()
	
	# Set to the first day of the week.
	current_date.subtract_days((weekday - first + 7) % 7)
	
	# Fill with dates.
	for i in range(7):
		week._dates.append(current_date.duplicate())
		current_date.add_days(1)
	
	return week


func _to_string() -> String:
	return "[%s]" % ", ".join(dates)


## Returns the week number.
## [br][br]
## In the tradional system, dates can belong to week 1 of the next year
## or last week of the previous year, so the user must inform which date to be used
## as reference through [param index] (otherwise the biggest will be used).
func get_week_number(number_system: WeekNumberSystem = WeekNumberSystem.FOUR_DAY, index: int = -1) -> int:
	match number_system:
		WeekNumberSystem.FOUR_DAY:
			# Get in which year is the week (4th day determines the year of that week).
			var year: int = dates[3].year
			
			# Get a date from week 1 of that year (January 4 is guarantee to be in the week 1).
			var week_one: Date = Date.new(year, 1, 4)
			
			# Calculate the days between them.
			var days_from_week_one: int = week_one.days_to(dates[3])
			
			return int(days_from_week_one / 7) + 1
		WeekNumberSystem.TRADITIONAL:
			# Get in which year is the date (two dates from same week can have different years).
			var year: int = dates[index].year
			
			# Get the first day of that year.
			var day_one: Date = Date.new(year, 1, 1)
			
			# Calculate the days between them.
			var days_from_day_one: int = day_one.days_to(dates[index])
			
			# Take in count that may not start at the initial weekday.
			var weekday_offset: int = day_one.get_weekday() - get_first_weekday()
			
			return int((days_from_day_one + weekday_offset) / 7) + 1
	return 0

#region Shortcuts
## Shortcut for [method Datelib.get_weekday] for the first day.
func get_first_weekday() -> Time.Weekday: return dates[0].get_weekday()
#endregion
