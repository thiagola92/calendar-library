class_name Calendar
extends RefCounted
## A utility library for generating calendar data.
##
## Calendar is a comprehensive library for creating calendar views, 
## including yearly, monthly, weekly overviews, and agendas. It adheres 
## to Godot's date handling conventions and [Time] singleton, with weeks 
## going from [code]Sunday = 0[/code] to [code]Saturday = 6[/code]. Just like [Time], 
## Calendar follows the Proleptic Gregorian Calendar, so the day before 
## 1582-10-15 is 1582-10-14, not 1582-10-04. Weekdays from 1582-10-15 are valid.
## [br][br]
## The Calendar library comes with a handy Date class (see [Calendar.Date]),
## which stores a date as [code]year[/code], [code]month[/code] and [code]day[/code], and comes with handy utility functions.
## [br][br]
## The library also facilitates formatted and localized date 
## representations through the CalendarLocale resource. Each Calendar 
## object is linked to a CalendarLocale, which can be customized 
## or replaced as needed.

const _POSIX_PLACEHOLDERS = "(%F|%Y|%y|%m|%B|%b|%-b|%d|%-d|%-m|%-y|%j|%-j|%A|%a|%-a|%u|%w)"

enum WeekdayFormat{
	## Show the weekday's full name
	WEEKDAY_FORMAT_FULL,
	## Show the weekday's name as an abbreviated version (e.g. "Mon" for "Monday")
	WEEKDAY_FORMAT_ABBR,
	## Show the weekday in a short form (e.g. "M" for "Monday")
	WEEKDAY_FORMAT_SHORT,
}

enum MonthFormat{
	## Show the month's full name
	MONTH_FORMAT_FULL,
	## Shows the month's name as an abbreviated version 
	## (e.g., "Jan" for "January").
	MONTH_FORMAT_ABBR,
	## Show month in a short form (e.g. "J" for "January")
	MONTH_FORMAT_SHORT,
}

enum WeekNumberSystem {
	## Calculates the week number where the first week
	## of the year is the one with at least four days. The starting day
	## of the week is determined by [param first_weekday].
	WEEK_NUMBER_FOUR_DAY,
	## Calculates the week number where the first week of the year is
	## always the one containing January 1.
	WEEK_NUMBER_TRADITIONAL,
}

## The weekday that is considered the first day of the week.
## Takes a [enum Time.Weekday] value where Sunday = 0 and Saturday = 6 
## (to align with Godot's Weekday standard)
var first_weekday: Time.Weekday = Time.WEEKDAY_MONDAY

## The week number system to use when calculating week numbers.
## See [enum WeekNumberSystem]
var week_number_system : WeekNumberSystem = WeekNumberSystem.WEEK_NUMBER_FOUR_DAY

## The calendar's localization settings for retrieving
## preformatted values. Each calendar object is assigned a CalendarLocale
## resource which default to English. To customize localization, 
## create and configure a new CalendarLocale
## resource, then assign it to [code]calendar_locale[/code].
var calendar_locale: CalendarLocale = CalendarLocale.new()


# Regex used for getting placeholder combinations in get_date_formatted()
var _posix_regex = RegEx.new()


func _init() -> void:
	_posix_regex.compile(_POSIX_PLACEHOLDERS)


## Returns an array with all weekdays in ascending order from [code]first_weekday[/code].
@warning_ignore("int_as_enum_without_cast")
func get_weekdays() -> Array[Time.Weekday]:
	var weekdays: Array[Time.Weekday] = []
	for i: Time.Weekday in range(7):
		weekdays.append((first_weekday + i) % 7)
	return weekdays


## Returns an array with all the weekday names, starting from [code]first_weekday[/code].
## [codeblock]
## cal.set_weekday(Time.WEEKDAY_THURSDAY)
## cal.get_weekdays_formatted(WeekdayFormat.WEEKDAY_FORMAT_FULL)
## # Outputs Thursday, Friday, Saturday, Sunday, Monday, Tuesday, Wednesday
## [/codeblock]
func get_weekdays_formatted(weekday_format: WeekdayFormat = WeekdayFormat.WEEKDAY_FORMAT_ABBR) -> Array[String]:
	var weekday_format_prefix: String = ""
	match weekday_format:
		WeekdayFormat.WEEKDAY_FORMAT_FULL:
			weekday_format_prefix = ""
		WeekdayFormat.WEEKDAY_FORMAT_ABBR:
			weekday_format_prefix = "abbr_"
		WeekdayFormat.WEEKDAY_FORMAT_SHORT:
			weekday_format_prefix = "short_"
	
	var all_weekdays: Array[String] = [
		calendar_locale.get(weekday_format_prefix + "sunday"),
		calendar_locale.get(weekday_format_prefix + "monday"),
		calendar_locale.get(weekday_format_prefix + "tuesday"),
		calendar_locale.get(weekday_format_prefix + "wednesday"),
		calendar_locale.get(weekday_format_prefix + "thursday"),
		calendar_locale.get(weekday_format_prefix + "friday"),
		calendar_locale.get(weekday_format_prefix + "saturday"),
	]
	
	var weekdays_formatted: Array[String] = []
	for i in range(7):
		var day_index: int = (first_weekday + i) % 7
		weekdays_formatted.append(all_weekdays[day_index])
	return weekdays_formatted


## Returns an array with all the month's names from "January" to "December".
func get_months_formatted(month_format: MonthFormat = MonthFormat.MONTH_FORMAT_ABBR) -> Array[String]:
	var month_format_prefix: String = ""
	match month_format:
		MonthFormat.MONTH_FORMAT_FULL:
			month_format_prefix = ""
		MonthFormat.MONTH_FORMAT_ABBR:
			month_format_prefix = "abbr_"
		MonthFormat.MONTH_FORMAT_SHORT:
			month_format_prefix = "short_"
	
	var months_formatted: Array[String] = [
		calendar_locale.get(month_format_prefix + "january"),
		calendar_locale.get(month_format_prefix + "february"),
		calendar_locale.get(month_format_prefix + "march"),
		calendar_locale.get(month_format_prefix + "april"),
		calendar_locale.get(month_format_prefix + "may"),
		calendar_locale.get(month_format_prefix + "june"),
		calendar_locale.get(month_format_prefix + "july"),
		calendar_locale.get(month_format_prefix + "august"),
		calendar_locale.get(month_format_prefix + "september"),
		calendar_locale.get(month_format_prefix + "october"),
		calendar_locale.get(month_format_prefix + "november"),
		calendar_locale.get(month_format_prefix + "december"),
	]
	
	return months_formatted


## Returns the number of leap days between [param from_year] and
## [param to_year]. By default, [param to_year] is exclusive. This
## can be changed by setting [param exclusive_to] to [code]false[/code].
@warning_ignore("integer_division")
func get_leap_days(from_year: int, to_year: int, exclusive_to: bool = true) -> int:
	from_year -= 1
	to_year -= exclusive_to as int
	var leap_from: int = from_year / 4 - from_year / 100 + from_year / 400
	var leap_to: int = to_year / 4 - to_year / 100 + to_year / 400
	return leap_to - leap_from


## Returns the weekday name for a given date.
func get_weekday_formatted(year: int, month: int, day: int, weekday_format: WeekdayFormat = WeekdayFormat.WEEKDAY_FORMAT_FULL) -> String:
	var weekday = DateUtil.get_weekday(year, month, day)
	var weekday_format_prefix: String = ""
	match weekday_format:
		WeekdayFormat.WEEKDAY_FORMAT_FULL:
			weekday_format_prefix = ""
		WeekdayFormat.WEEKDAY_FORMAT_ABBR:
			weekday_format_prefix = "abbr_"
		WeekdayFormat.WEEKDAY_FORMAT_SHORT:
			weekday_format_prefix = "short_"
	
	match weekday:
		1: return calendar_locale.get(weekday_format_prefix + "monday")
		2: return calendar_locale.get(weekday_format_prefix + "tuesday")
		3: return calendar_locale.get(weekday_format_prefix + "wednesday")
		4: return calendar_locale.get(weekday_format_prefix + "thursday")
		5: return calendar_locale.get(weekday_format_prefix + "friday")
		6: return calendar_locale.get(weekday_format_prefix + "saturday")
		0: return calendar_locale.get(weekday_format_prefix + "sunday")
		7: return calendar_locale.get(weekday_format_prefix + "sunday")
	
	printerr("Can't get a formatted weekday: %s" % weekday)
	return ""


## Returns the name for a given month (1-12).
func get_month_formatted(month: int, month_format: MonthFormat = MonthFormat.MONTH_FORMAT_ABBR) -> String:
	var month_format_prefix: String = ""
	match month_format:
		MonthFormat.MONTH_FORMAT_FULL:
			month_format_prefix = ""
		MonthFormat.MONTH_FORMAT_ABBR:
			month_format_prefix = "abbr_"
		MonthFormat.MONTH_FORMAT_SHORT:
			month_format_prefix = "short_"
	
	match month:
		1: return calendar_locale.get(month_format_prefix + "january")
		2: return calendar_locale.get(month_format_prefix + "february")
		3: return calendar_locale.get(month_format_prefix + "march")
		4: return calendar_locale.get(month_format_prefix + "april")
		5: return calendar_locale.get(month_format_prefix + "may")
		6: return calendar_locale.get(month_format_prefix + "june")
		7: return calendar_locale.get(month_format_prefix + "july")
		8: return calendar_locale.get(month_format_prefix + "august")
		9: return calendar_locale.get(month_format_prefix + "september")
		10: return calendar_locale.get(month_format_prefix + "october")
		11: return calendar_locale.get(month_format_prefix + "november")
		12: return calendar_locale.get(month_format_prefix + "december")
	
	printerr("Can't get a formatted month: %s" % month)
	return ""


## Returns an array representing each month of a given year. Each 
## month is also an array of Date objects corresponding to each day in that month.
## [br][br]
## [param include_adjacent_days] If [code]true[/code], includes dates from adjacent 
## months in the starting and ending weeks. If [code]false[/code], 
## the positions in the array for these dates are set to [code]0[/code].
## [br][br]
## Set [param force_six_weeks] to [code]true[/code] to ensure the 
## return of six weeks for each month, even if the month spans 
## fewer than six weeks. This is beneficial for consistent presentation 
## across multiple months.
func get_calendar_year(year: int, include_adjacent_days: bool = false, force_six_weeks: bool = true) -> Array:
	var year_calendar: Array = []
	
	for month in range(1, 13):  # For each month in the year
		var month_calendar = get_calendar_month(year, month, include_adjacent_days, force_six_weeks)
		year_calendar.append(month_calendar)

	return year_calendar


## Returns an array of weeks, where each week is an array of Date objects 
## for every day in the specified [param year] and [param month].
## [br][br]
## [param include_adjacent_days] If [code]true[/code], includes dates from adjacent 
## months in the starting and ending weeks. If [code]false[/code], 
## the positions in the array for these dates are set to [code]0[/code].
## [br][br]
## Set [param force_six_weeks] to [code]true[/code] to ensure the 
## return of six weeks for each month, even if the month spans 
## fewer than six weeks. This is beneficial for consistent presentation 
## across multiple months.
@warning_ignore("int_as_enum_without_cast")
func get_calendar_month(year: int, month: int, include_adjacent_days: bool = false, force_six_weeks: bool = false) -> Array:
	if not _is_month_valid(month):
		return []
	
	var days_in_month: int = DateUtil.get_days_in_month(year, month)
	var first_day_weekday: Time.Weekday = DateUtil.get_weekday(year, month, 1)
	var prev_month: int = month - 1
	var prev_year: int = year
	if prev_month < 1:
		prev_month = 12
		prev_year -= 1
	var prev_month_days: int = DateUtil.get_days_in_month(prev_year, prev_month)
	var next_month: int = month + 1
	var next_year: int = year
	if next_month > 12:
		next_month = 1
		next_year += 1
	
	# Adjust for the first weekday setting
	first_day_weekday = (first_day_weekday - first_weekday + 7) % 7
	
	var calendar: Array = []
	var week: Array = [0, 0, 0, 0, 0, 0, 0]
	var day: int = 1 - first_day_weekday
	
	while day <= days_in_month or (force_six_weeks and calendar.size() < 6):
		for i in range(7):
			if day > 0 and day <= days_in_month:
				week[i] = Date.new(year, month, day)
			elif include_adjacent_days:
				if day <= 0:
					var adj_day = prev_month_days + day
					week[i] = Date.new(prev_year, prev_month, adj_day)
				elif day > days_in_month:
					var adj_day = day - days_in_month
					week[i] = Date.new(next_year, next_month, adj_day)
			else:
				week[i] = 0
			
			day += 1
		
		calendar.append(week.duplicate())
		week.fill(0)
	
	return calendar


## Returns an array of Date objects for each day in the week containing 
## the specified [param year], [param month], and [param day]. 
## Use [param days_in_week] to define the number of days included, 
## useful for representing shortened weeks such as workweeks.
@warning_ignore("int_as_enum_without_cast")
func get_calendar_week(year: int, month: int, day: int, days_in_week: int = 7) -> Array[Date]:
	if not DateUtil.is_valid(year, month, day):
		return []
	if days_in_week < 1:
		push_error("days_in_week has to be greater than 0. Got: %s" % days_in_week)
		return []
	
	var dates : Array[Date] = []
	var day_of_week: Time.Weekday = DateUtil.get_weekday(year, month, day)
	
	var current_day: Time.Weekday = day - ((day_of_week - first_weekday + 7) % 7)
	var current_month: int = month
	var current_year: int = year
	
	for i in range(days_in_week):
		if current_day <= 0:
			current_month -= 1
			if current_month < 1:
				current_month = 12
				current_year -= 1
			current_day = DateUtil.get_days_in_month(current_year, current_month) + current_day
		elif current_day > DateUtil.get_days_in_month(current_year, current_month):
			current_day = 1
			current_month += 1
			if current_month > 12:
				current_month = 1
				current_year += 1
		
		var date = Date.new(current_year, current_month, current_day)
		dates.append(date)
		current_day += 1
	
	return dates


## Sets the first day of the week for the calendar. Any day can be chosen.
## Accepts a value from [enum Time.Weekday], where Sunday = 0 and
## Saturday = 6.
## [codeblock]
## # Set the calendar's first day of the week to Monday.
## var cal = Calendar.new()
## cal.set_first_weekday(Time.WEEKDAY_MONDAY)
## [/codeblock]
@warning_ignore("shadowed_variable")
func set_first_weekday(first_weekday : Time.Weekday) -> void:
	self.first_weekday = first_weekday


## Assign a [code]CalendarLocale[/code] resource to the calendar.
func set_calendar_locale(path: String) -> void:
	if path.is_empty():
		push_error("CalendarLocale path can not be empty.")
		return
	if not (path.ends_with(".tres") or path.ends_with(".res")):
		push_error("CalendarLocale path must point to a .tres or .res resource: %s" % path)
		return
	if not ResourceLoader.exists(path):
		push_error("CalendarLocale resource was not found at path: %s" % path)
		return
	
	var locale_resource: Resource = load(path)
	if locale_resource == null or not (locale_resource is CalendarLocale):
		push_error("Resource is not a CalendarLocale: %s" % path)
		return
	
	calendar_locale = locale_resource as CalendarLocale


## Set which week number system to use when calculating week numbers.
## See [enum WeekNumberSystem]
@warning_ignore("shadowed_variable")
func set_week_number_system(week_number_system: WeekNumberSystem) -> void:
	self.week_number_system = week_number_system


## Returns the week number for the given [param year], [param month] and [param day].
func get_week_number(year: int, month: int, day: int) -> int:
	if not DateUtil.is_valid(year, month, day):
		return 0
	
	var weekday_offset: int = (DateUtil.get_weekday(year, month, day) - first_weekday + 7) % 7
	var week_start: Date = Date.new(year, month, day)
	week_start.subtract_days(weekday_offset)
	
	match week_number_system:
		WeekNumberSystem.WEEK_NUMBER_FOUR_DAY:
			# The 4th day of the week determines the week-year in the "four-day" system.
			var majority_day: Date = week_start.duplicate()
			majority_day.add_days(3)
			
			# The week containing January 4 is always week 1 in the four-day system.
			var week_one_offset: int = (DateUtil.get_weekday(majority_day.year, 1, 4) - first_weekday + 7) % 7
			var week_one_start: Date = Date.new(majority_day.year, 1, 4)
			week_one_start.subtract_days(week_one_offset)
			
			var days_from_week_one: int = week_start.days_to(week_one_start)
			return int(floor(days_from_week_one / 7.0)) + 1
		
		WeekNumberSystem.WEEK_NUMBER_TRADITIONAL:
			# Week 1 is the week containing January 1.
			var week_one_offset: int = (DateUtil.get_weekday(year, 1, 1) - first_weekday + 7) % 7
			var week_one_start: Date = Date.new(year, 1, 1)
			week_one_start.subtract_days(week_one_offset)
			
			var next_week_one_offset: int = (DateUtil.get_weekday(year + 1, 1, 1) - first_weekday + 7) % 7
			var next_week_one_start: Date = Date.new(year + 1, 1, 1)
			next_week_one_start.subtract_days(next_week_one_offset)
			
			# Dates can belong to week 1 of the next year or the last week of the previous year.
			if week_start.is_before(week_one_start):
				var prev_week_one_offset: int = (DateUtil.get_weekday(year - 1, 1, 1) - first_weekday + 7) % 7
				week_one_start = Date.new(year - 1, 1, 1)
				week_one_start.subtract_days(prev_week_one_offset)
			elif not week_start.is_before(next_week_one_start):
				week_one_start = next_week_one_start
			
			var days_from_week_one: int = week_start.days_to(week_one_start)
			return int(floor(days_from_week_one / 7.0)) + 1
	
	return 0


## Returns an array of all the week numbers of the given month.
## [br][br]
## Set [param force_six_weeks] to [code]true[/code] to ensure the 
## return of six weeks for each month, even if the month spans 
## fewer than six weeks. This is beneficial for consistent presentation 
## across multiple months.
func get_weeks_of_month(year: int, month: int, force_six_weeks: bool = false) -> Array[int]:
	if not _is_month_valid(month):
		return []
	
	var weeks : Array[int] = []
	var days_in_month = DateUtil.get_days_in_month(year, month)

	# Iterate through all days in the month and add each week transition.
	# This avoids missing a final week that can start near month end.
	var previous_week = get_week_number(year, month, 1)
	weeks.append(previous_week)
	for day in range(2, days_in_month + 1):
		var current_week = get_week_number(year, month, day)
		if current_week != previous_week:
			weeks.append(current_week)
			previous_week = current_week

	# Ensure six weeks are returned, if needed
	if force_six_weeks and weeks.size() < 6:
		var next_month = month + 1
		var next_year = year
		if next_month > 12:
			next_month = 1
			next_year += 1
		var day_in_next_month = 1
		while weeks.size() < 6:
			var week_in_next_month = get_week_number(next_year, next_month, day_in_next_month)
			if week_in_next_month != weeks[weeks.size() - 1]:
				weeks.append(week_in_next_month)
			day_in_next_month += 7

	return weeks


## Returns an array of Date objects for a number of days, defined by [param days],
## starting from [param year], [param month], and [param day].
## Good for presenting a set of days or creating agenda-style overviews.
## [br][br]
## Set [param exclusive] to [code]true[/code] to exclude the last day
## in the range.
func get_days_of_range(days: int, year: int, month: int, day: int, exclusive: bool = false) -> Array[Date]:
	if days < 0:
		push_error("days can not be negative. Got: %s" % days)
		return []
	if not DateUtil.is_valid(year, month, day):
		return []
	
	var days_range: Array[Date] = []
	var total_days: int = days - 1 if exclusive else days
	
	for _i in range(total_days):
		var date = Date.new(year, month, day)
		days_range.append(date)
		day += 1
		if day > DateUtil.get_days_in_month(year, month):
			day = 1
			month += 1
			if month > 12:
				month = 1
				year += 1

	return days_range


## Returns a formatted string for a specified date, using the [param format] pattern.
## This function adheres to POSIX placeholder standards, limited to placeholders for 
## years, months, days, and weekdays (see list below of supported placeholders). The 
## pattern can include various placeholders and any dividers between them.
## [codeblock]
## var pattern = "%Y-%m-%d"
## var formatted_date = get_date_formatted(2023, 12, 03, pattern)
## print(formatted_date) # Will output 2023-12-03
## [/codeblock]
## [codeblock]
## var pattern = "%A, %B %d, %Y"
## var formatted_date = get_date_formatted(2023, 12, 03, pattern)
## print(formatted_date) # Will output Sunday, December 3, 2023
## [/codeblock]
## [b]%Y[/b] - Full year in four digits (e.g., 2023).[br]
## [b]%y[/b] - Year in two digits (e.g., 23 for 2023).[br]
## [b]%-y[/b] - Year in two digits without zero-padding (e.g., 3 for 2003).[br]
## [b]%m[/b] - Month as a zero-padded number (e.g., 02 for February).[br]
## [b]%-m[/b] - Month as a number without zero-padding (e.g., 2 for February).[br]
## [b]%d[/b] - Day of the month as a zero-padded number (e.g., 05).[br]
## [b]%-d[/b] - Day of the month without zero-padding (e.g., 5).[br]
## [b]%F[/b] - Date in ISO8601 standard format (e.g., 2023-02-05)[br]
## [br]
## [b]%B[/b] - Full month name from [code]CalendarLocale[/code] (e.g., February).[br]
## [b]%b[/b] - Abbreviated month name from [code]CalendarLocale[/code] (e.g., Feb).[br]
## [b]%-b[/b] - Short month name from [code]CalendarLocale[/code] (e.g., F for February).[br]
## [b]%A[/b] - Full weekday name from [code]CalendarLocale[/code] (e.g., Monday).[br]
## [b]%a[/b] - Abbreviated weekday name from [code]CalendarLocale[/code] (e.g., Mon).[br]
## [b]%-a[/b] - Short weekday name from [code]CalendarLocale[/code] (e.g., M for Monday).[br]
## [br]
## [b]%j[/b] - Day of the year as a zero-padded number (e.g., 065 for the 65th day).[br]
## [b]%-j[/b] - Day of the year without zero-padding (e.g., 65 for the 65th day).[br]
## [b]%u[/b] - Weekday as a number (Monday = 1, Sunday = 7).[br]
## [b]%w[/b] - Weekday as a number (Sunday = 0, Saturday = 6).[br]
@warning_ignore("unused_parameter")
func get_date_formatted(year: int, month: int, day: int, format: String = "%Y-%m-%d") -> String:
	if not DateUtil.is_valid(year, month, day):
		return ""
	
	var results: Array[RegExMatch] = _posix_regex.search_all(format)
	var format_posix_placeholders: Array = []
	for result in results:
		var matched_string = format.substr(result.get_start(), result.get_end() - result.get_start())
		format_posix_placeholders.append(matched_string)

	var result: String = format
	var seen_placeholders: Dictionary = {}
	for format_posix_placeholder in format_posix_placeholders:
		if seen_placeholders.has(format_posix_placeholder):
			continue
		seen_placeholders[format_posix_placeholder] = true
		
		var replacement: String = ""
		match format_posix_placeholder:
			"%Y": replacement = str(year)
			"%y": replacement = str(year).right(2)
			"%-y": replacement = str(int(str(year).right(2)))
			"%m": replacement = str(month).pad_zeros(2)
			"%-m": replacement = str(month).lstrip("0")
			"%d": replacement = str(day).pad_zeros(2)
			"%-d": replacement = str(day).lstrip("0")
			"%F": replacement = "%s-%02d-%02d" % [year, month, day]
			"%B": replacement = get_month_formatted(month, MonthFormat.MONTH_FORMAT_FULL)
			"%b": replacement = get_month_formatted(month, MonthFormat.MONTH_FORMAT_ABBR)
			"%-b": replacement = get_month_formatted(month, MonthFormat.MONTH_FORMAT_SHORT)
			"%A": replacement = get_weekday_formatted(year, month, day, WeekdayFormat.WEEKDAY_FORMAT_FULL)
			"%a": replacement = get_weekday_formatted(year, month, day, WeekdayFormat.WEEKDAY_FORMAT_ABBR)
			"%-a": replacement = get_weekday_formatted(year, month, day, WeekdayFormat.WEEKDAY_FORMAT_SHORT)
			"%j": replacement = str(DateUtil.get_day_of_year(year, month, day)).pad_zeros(3)
			"%-j": replacement = str(DateUtil.get_day_of_year(year, month, day))
			"%u": replacement = str(DateUtil.get_weekday_iso(year, month, day))
			"%w": replacement = str(DateUtil.get_weekday(year, month, day))
			_: continue
		
		result = result.replace(format_posix_placeholder, replacement)
	
	return result


## Returns the given [param year], [param month] and [param day] in the format specified 
## by the current CalendarLocale's Date Format and Divider Symbol.
## [br][br]
## Set [param four_digit_year] to [code]false[/code] to get the year with two digits instead of four.
func get_date_locale_format(year: int, month: int, day: int, four_digit_year: bool = true) -> String:
	var year_format: String = "%Y" if four_digit_year else "%y"
	var divider: String = calendar_locale.divider_symbol
	var format: String = ""
	
	var date_format: String = "%s%s%s%s%s"
	match calendar_locale.date_format:
		0: # "Year-Month-Day"
			format = date_format % [year_format, divider, "%m", divider, "%d"]
		1: # "Day-Month-Year"
			format = date_format % ["%d", divider, "%m", divider, year_format]
		2: # "Month-Day-Year"
			format = date_format % ["%m", divider, "%d", divider, year_format]
		3: # "Year-Day-Month"
			format = date_format % [year_format, divider, "%d", divider, "%m"]
	
	return get_date_formatted(year, month, day, format)


@warning_ignore("integer_division")
func _get_shifted_weekday(year: int, month: int , day: int) -> int:
	# This Zeller's work a bit different than get_weekday()
	# It shifts which day is 1 depending on first_weekday and should be used
	# separate so that get_weekday_formatted() can be used in isolation
	if month < 3:
		month += 12
		year -= 1
	var k: int = year % 100
	var j: int = int(year / 100)
	var f: int = day + (13 * (month + 1) / 5) + k + (k / 4) + (j / 4) - 2 * j
	var adjusted_weekday: int = (f + 7 - first_weekday + 7) % 7
	return adjusted_weekday


func _is_month_valid(month: int) -> bool:
	if month < 1 or month > 12:
		push_error("Month has to be 1 - 12. Got: %s" % month)
		return false
	return true
