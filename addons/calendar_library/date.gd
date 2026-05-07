class_name Date
extends RefCounted
## A utility class for storing and handling dates.
##
## Date stores data about a specific date, encompassing the year, month, and
## day. It is utilized by the [Calendar] library and is typically used in
## situations where information about the entire date is practical (rather
## than only a year, a month, or a day).

## The year of this date.
var year: int:
	get: return _year
	set(y): push_error("Can't modify a read-only property.")

## The month of this date. An integer value from 1 to 12 representing January to December.
var month: int:
	get: return _month
	set(m): push_error("Can't modify a read-only property.")

## The day of this date. An integer value from 1 to 31.
var day: int:
	get: return _day
	set(d): push_error("Can't modify a read-only property.")

var _year: int = 1

var _month: int = 1

var _day: int = 1


## A static function that returns a Date object
## with the specific date or null if the date is invalid.
## [codeblock]
## var date = Date.get_date(2026, 5, 7)
##
## if date == null:
##   print("Invalid date")
## else:
##   print(date)
## [/codeblock]
@warning_ignore("shadowed_variable")
static func get_date(year: int, month: int, day: int) -> Date:
	var date := Date.new()
	
	if date.set_date(year, month, day):
		return date
	
	return null


## A static function that returns a Date object with todays date.
## The date is fetched from the system.
## [codeblock]
## var today = Date.get_today()
## print(today) # Outputs the current date from the system
## [/codeblock]
static func get_today() -> Date:
	var today: Dictionary = Time.get_date_dict_from_system()
	return Date.new(today.year, today.month, today.day)


@warning_ignore("shadowed_variable")
func _init(year: int = 1, month: int = 1, day: int = 1) -> void:
	set_date(year, month, day)


# Present the date as "Year-Month-Day" when printed (i.e., 2023-12-01).
# This is a build in function from Godot that changed how a class
# behaves when printed.
func _to_string() -> String:
	return "%d-%02d-%02d" % [year, month, day]


## Set the year, month and day of this Date. Throws an error if the 
## date is not a valid date.
@warning_ignore("shadowed_variable")
func set_date(year: int, month: int, day: int) -> bool:
	var previous_year := _year
	var previous_month := _month
	var previous_day := _day
	
	_year = year
	_month = month
	_day = day
	
	if not is_valid():
		_year = previous_year
		_month = previous_month
		_day = previous_day
		return false
	
	return true


## Returns a new Date object which is a copy of this Date.
func duplicate() -> Date:
	return Date.new(year, month, day)


## Returns [code]true[/code] or [code]false[/code]
## if the date is a valid date or not.
func is_valid() -> bool:
	var error_msg = "Date is not valid (%s, %s, %s): " % [year, month, day]
	
	if month < 1 or month > 12:
		push_error(error_msg + "Month has to be 1 - 12. ")
		return false
	
	if day < 1:
		push_error(error_msg + "Days can not be less than 1. ")
		return false
	
	if day > get_days_in_month():
		push_error(error_msg + "Too many days in month. ")
		return false
	
	if month == 2 and day == 29 and not is_leap_year():
		push_error(error_msg + "Day can not be 29 in a non-leap year February. ")
		return false
	
	return true


## Returns [code]true[/code] or [code]false[/code] depending on whether
## the current date is a leap year or not.
func is_leap_year() -> bool:
	return (year % 4 == 0 and (year % 100 != 0 or year % 400 == 0))


## Returns [code]true[/code] if this Date is before the provided date.
func is_before(date: Date) -> bool:
	if year < date.year:
		return true
	elif year > date.year:
		return false
	elif month < date.month:
		return true
	elif month > date.month:
		return false
	return day < date.day


## Returns [code]true[/code] if this Date is after the provided date.
func is_after(date: Date) -> bool:
	if year > date.year:
		return true
	elif year < date.year:
		return false
	elif month > date.month:
		return true
	elif month < date.month:
		return false
	return day > date.day


## Returns [code]true[/code] if this Date is the same as the provided date.
func is_equal(date: Date) -> bool:
	return year == date.year and month == date.month and day == date.day


## Returns the number of days in the current month. If the year
## is a leap year February will return 29 days.
func get_days_in_month() -> int:
	var days_in_month: Array[int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	
	if month == 2 and is_leap_year():
		return 29
	
	return days_in_month[month - 1]


## Returns the weekday of the current date as a [code]Time.Weekday[/code] 
## value where Sunday = 0 and Saturday = 6.
@warning_ignore("integer_division")
func get_weekday() -> Time.Weekday:
	# Zeller's Congruence algorithm to find the day of the week
	var calc_year := year
	var calc_month := month
	if calc_month < 3:
		calc_month += 12
		calc_year -= 1
	var k: int = calc_year % 100
	var j: int = int(calc_year / 100)
	var f = day + (13 * (calc_month + 1) / 5) + k + (k / 4) + (j / 4) - 2 * j
	
	# Adjusted Zeller's Congruence for Godot's Sunday = 0
	return (f + 6) % 7 as Time.Weekday


## Similar to [method get_weekday] but returns an integer value 
## where Monday = 1 and Sunday = 7, according to the ISO8601 standard.
func get_weekday_iso() -> int:
	var weekday: Time.Weekday = get_weekday()
	return weekday if weekday != 0 else 7


## Returns the ordinal day for the given [member year], [member month] and [member day].
func get_day_of_year() -> int:
	var days_in_month: Array[int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	
	if is_leap_year():
		days_in_month[1] = 29
	
	var day_number: int = day
	
	for i in range(month - 1):
		day_number += days_in_month[i]
	
	return day_number

#region Math over dates

## Add any number of days to this date.
func add_days(days: int) -> void:
	if days < 0:
		subtract_days(-days)
		return
	_day += days
	while _day > get_days_in_month():
		_day -= get_days_in_month()
		_month += 1
		if _month > 12:
			_month = 1
			_year += 1


## Adds a specified number of months to the date. 
## [br][br]
## If the resulting date's day does not correspond to the number of days in the new month, 
## it will be adjusted to the nearest valid day. For example, if the day 
## is 31 and the new month is June, the day will be set to 30. Additionally, 
## February 29 will be adjusted to February 28 in non-leap years.
func add_months(months: int) -> void:
	if months < 0:
		subtract_months(-months)
		return
	_month += months
	while _month > 12:
		_month -= 12
		_year += 1
	var days_in_new_month: int = get_days_in_month()
	if _day > days_in_new_month:
		_day = days_in_new_month


## Adds any number of years to the date. February 29 will be set 
## to February 28 if the new year is not a leap year.
func add_years(years: int) -> void:
	_year += years
	if _month == 2 and _day == 29 and not is_leap_year():
		_day = 28


## Subtract any number of days from this date.
func subtract_days(days: int) -> void:
	if days < 0:
		add_days(-days)
		return
	_day -= days
	while _day < 1:
		_month -= 1
		if _month < 1:
			_month = 12
			_year -= 1
		_day += get_days_in_month()


## Subtracts a specified number of months from the date. 
## [br][br]
## If the resulting date's day does not correspond to the number of days in the new month, 
## it will be adjusted to the nearest valid day. For example, if the day 
## is 31 and the new month is June, the day will be set to 30. Additionally, 
## February 29 will be adjusted to February 28 in non-leap years.
func subtract_months(months: int) -> void:
	if months < 0:
		add_months(-months)
		return
	_month -= months
	while _month < 1:
		_month += 12
		_year -= 1
	var days_in_new_month: int = get_days_in_month()
	if _day > days_in_new_month:
		_day = days_in_new_month


## Subtracts any number of years from the date. February 29 will be set 
## to February 28 if the new year is not a leap year.
func subtract_years(years: int) -> void:
	_year -= years
	if _month == 2 and _day == 29 and not is_leap_year():
		_day = 28


## Return the number of days between two Date objects. Is only accurate
## when dates are after the year 1582.
func days_to(date: Date) -> int:
	return self._to_julian_day() - date._to_julian_day()


# Helper function to calculate how many days are between two Date objects
@warning_ignore("integer_division")
func _to_julian_day() -> int:
	# Algorithm to convert a Gregorian date to a Julian Day Number.
	# This is a simplified version and works for dates after 1582.
	var a: int = (14 - _month) / 12
	var y: int = _year + 4800 - a
	var m: int = _month + 12 * a - 3
	var jdn: int = _day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
	return jdn

#endregion
