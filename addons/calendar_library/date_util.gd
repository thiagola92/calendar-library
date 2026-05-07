class_name DateUtil
extends RefCounted

const DAYS_IN_MONTH: Array[int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]


## Returns the number of days in the given [param year] and [param month].
## If is a leap year and February, it will return 29 days.
static func get_days_in_month(year: int, month: int) -> int:
	if month == 2 and is_leap_year(year):
		return 29
	return DAYS_IN_MONTH[month - 1]


## Returns the number of days in the given [param year].
## If is a leap year 366, otherwise 365.
static func get_days_in_year(year: int) -> int:
	return 366 if is_leap_year(year) else 365


## Returns the ordinal day for the given [param year], [param month] and [param day].
static func get_day_of_year(year: int, month: int, day: int) -> int:
	var day_number: int = day
	
	for i in range(month - 1):
		day_number += DAYS_IN_MONTH[i]
	
	# If we are after February and is leap year, we have to
	# take in count that it had one day more (29 days instead of 28).
	if month > 2 and is_leap_year(year):
		day_number += 1
	
	return day_number


## Returns the specific [param year], [param month] and [param day]
## as Julian day.
## [br][br]
## Julian day is used a lot in softwares for easily
## calculating elapsed days between two events.
## [br][br]
## [b]Note[/b]: Is only accurate for dates after the year 1582.
@warning_ignore("integer_division")
static func get_julian_day(year: int, month: int, day: int) -> int:
	# This is a simplified version and works for dates after 1582.
	var a: int = (14 - month) / 12
	var y: int = year + 4800 - a
	var m: int = month + 12 * a - 3
	var jdn: int = day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
	return jdn


## Returns the weekday for [param year], [param month] and [param day]
## as a [code]Time.Weekday[/code] value where Sunday = 0 and Saturday = 6.
@warning_ignore("integer_division")
static func get_weekday(year: int, month: int, day: int) -> Time.Weekday:
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
static func get_weekday_iso(year: int, month: int, day: int) -> int:
	var weekday: Time.Weekday = get_weekday(year, month, day)
	return weekday if weekday != 0 else 7


## Returns [code]true[/code] or [code]false[/code] depending
## on whether [param year] is a leap year or not.
static func is_leap_year(year: int) -> bool:
	return (year % 4 == 0 and (year % 100 != 0 or year % 400 == 0))


## Returns [code]true[/code] or [code]false[/code] if the
## combination of [param year], [param month] and [param day]
## is a valid date or not.
static func is_valid(year: int, month: int, day: int) -> bool:
	var error_msg = "Invalid date (%s, %s, %s): " % [year, month, day]
	
	if month < 1 or month > 12:
		push_error(error_msg + "Month has to be 1 - 12. ")
		return false
	
	if day < 1:
		push_error(error_msg + "Days can not be less than 1. ")
		return false
	
	if day > get_days_in_month(year, month):
		push_error(error_msg + "Too many days for the specific month. ")
		return false
	
	return true
