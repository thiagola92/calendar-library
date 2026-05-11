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
## The library also facilitates formatted and localized date 
## representations through the CalendarLocale resource. Each Calendar 
## object is linked to a CalendarLocale, which can be customized 
## or replaced as needed.

## The weekday that is considered the first day of the week.
## Takes a [enum Time.Weekday] value where Sunday = 0 and Saturday = 6 
## (to align with Godot's Weekday standard)
var first_weekday: Time.Weekday = Time.WEEKDAY_MONDAY

## The week number system to use when calculating week numbers.
## See [enum Calendarlib.WeekNumberSystem]
var week_number_system : Calendarlib.WeekNumberSystem = Calendarlib.WeekNumberSystem.FOUR_DAY

## The calendar's localization settings for retrieving
## preformatted values. Each calendar object is assigned a CalendarLocale
## resource which default to English. To customize localization, 
## create and configure a new CalendarLocale
## resource, then assign it to [code]locale[/code].
var locale: CalendarLocale = CalendarLocale.new()


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
	
	var days_in_month: int = Datelib.get_days_in_month(year, month)
	var first_day_weekday: Time.Weekday = Datelib.get_weekday(year, month, 1)
	var prev_month: int = month - 1
	var prev_year: int = year
	if prev_month < 1:
		prev_month = 12
		prev_year -= 1
	var prev_month_days: int = Datelib.get_days_in_month(prev_year, prev_month)
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
	if not Datelib.is_valid(year, month, day):
		return []
	if days_in_week < 1:
		push_error("days_in_week has to be greater than 0. Got: %s" % days_in_week)
		return []
	
	var dates : Array[Date] = []
	var day_of_week: Time.Weekday = Datelib.get_weekday(year, month, day)
	
	var current_day: Time.Weekday = day - ((day_of_week - first_weekday + 7) % 7)
	var current_month: int = month
	var current_year: int = year
	
	for i in range(days_in_week):
		if current_day <= 0:
			current_month -= 1
			if current_month < 1:
				current_month = 12
				current_year -= 1
			current_day = Datelib.get_days_in_month(current_year, current_month) + current_day
		elif current_day > Datelib.get_days_in_month(current_year, current_month):
			current_day = 1
			current_month += 1
			if current_month > 12:
				current_month = 1
				current_year += 1
		
		var date = Date.new(current_year, current_month, current_day)
		dates.append(date)
		current_day += 1
	
	return dates


## Returns the week number for the given [param year], [param month] and [param day].
func get_week_number(year: int, month: int, day: int) -> int:
	if not Datelib.is_valid(year, month, day):
		return 0
	
	var weekday_offset: int = (Datelib.get_weekday(year, month, day) - first_weekday + 7) % 7
	var week_start: Date = Date.new(year, month, day)
	week_start.subtract_days(weekday_offset)
	
	match week_number_system:
		Calendarlib.WeekNumberSystem.FOUR_DAY:
			# The 4th day of the week determines the week-year in the "four-day" system.
			var majority_day: Date = week_start.duplicate()
			majority_day.add_days(3)
			
			# The week containing January 4 is always week 1 in the four-day system.
			var week_one_offset: int = (Datelib.get_weekday(majority_day.year, 1, 4) - first_weekday + 7) % 7
			var week_one_start: Date = Date.new(majority_day.year, 1, 4)
			week_one_start.subtract_days(week_one_offset)
			
			var days_from_week_one: int = week_start.days_to(week_one_start)
			return int(floor(days_from_week_one / 7.0)) + 1
		
		Calendarlib.WeekNumberSystem.TRADITIONAL:
			# Week 1 is the week containing January 1.
			var week_one_offset: int = (Datelib.get_weekday(year, 1, 1) - first_weekday + 7) % 7
			var week_one_start: Date = Date.new(year, 1, 1)
			week_one_start.subtract_days(week_one_offset)
			
			var next_week_one_offset: int = (Datelib.get_weekday(year + 1, 1, 1) - first_weekday + 7) % 7
			var next_week_one_start: Date = Date.new(year + 1, 1, 1)
			next_week_one_start.subtract_days(next_week_one_offset)
			
			# Dates can belong to week 1 of the next year or the last week of the previous year.
			if week_start.is_before(week_one_start):
				var prev_week_one_offset: int = (Datelib.get_weekday(year - 1, 1, 1) - first_weekday + 7) % 7
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
	var days_in_month = Datelib.get_days_in_month(year, month)

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
	if not Datelib.is_valid(year, month, day):
		return []
	
	var days_range: Array[Date] = []
	var total_days: int = days - 1 if exclusive else days
	
	for _i in range(total_days):
		var date = Date.new(year, month, day)
		days_range.append(date)
		day += 1
		if day > Datelib.get_days_in_month(year, month):
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
	if not Datelib.is_valid(year, month, day):
		return ""
	
	var results: Array[RegExMatch] = Calendarlib._posix_regex.search_all(format)
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
			"%B": replacement = locale.get_month(
				month as Time.Month,
				CalendarLocale.NameFormat.FULL
			)
			"%b": replacement = locale.get_month(
				month as Time.Month,
				CalendarLocale.NameFormat.ABBR
			)
			"%-b": replacement = locale.get_month(
				month as Time.Month,
				CalendarLocale.NameFormat.SHORT
			)
			"%A": replacement = locale.get_weekday(
				Datelib.get_weekday(year, month, day),
				CalendarLocale.NameFormat.FULL
			)
			"%a": replacement = locale.get_weekday(
				Datelib.get_weekday(year, month, day),
				CalendarLocale.NameFormat.ABBR
			)
			"%-a": replacement = locale.get_weekday(
				Datelib.get_weekday(year, month, day),
				CalendarLocale.NameFormat.SHORT
			)
			"%j": replacement = str(Datelib.get_day_of_year(year, month, day)).pad_zeros(3)
			"%-j": replacement = str(Datelib.get_day_of_year(year, month, day))
			"%u": replacement = str(Datelib.get_weekday_iso(year, month, day))
			"%w": replacement = str(Datelib.get_weekday(year, month, day))
			_: continue
		
		result = result.replace(format_posix_placeholder, replacement)
	
	return result


## Returns the given [param year], [param month] and [param day] in the format specified 
## by the current CalendarLocale's Date Format and Divider Symbol.
## [br][br]
## Set [param four_digit_year] to [code]false[/code] to get the year with two digits instead of four.
func get_date_locale_format(year: int, month: int, day: int, four_digit_year: bool = true) -> String:
	var year_format: String = "%Y" if four_digit_year else "%y"
	var divider: String = locale.divider_symbol
	var format: String = ""
	
	var date_format: String = "%s%s%s%s%s"
	match locale.date_format:
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
	# separate so that get_weekday_name() can be used in isolation
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
