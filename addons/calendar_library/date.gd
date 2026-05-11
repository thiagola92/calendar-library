class_name Date
extends RefCounted
## A class for storing data about a specific date and operate over it.
##
## The proper way to create this object is through [method get_date],
## because it will return the object or [code]null[/code] if is an invalid date.
## Only use [code]Date.new()[/code] if you know that the date is correct, otherwise
## it will set the default values for year, month and day.


## The year of this date.
## [br][br]
## [b]Note[/b]: Read-only variable, use [method set_date] instead.
var year: int:
	get: return _year
	set(y): push_error("Can't modify a read-only property.")

## The month of this date. An integer value from 1 to 12 representing January to December.
## [br][br]
## [b]Note[/b]: Read-only variable, use [method set_date] instead.
var month: int:
	get: return _month
	set(m): push_error("Can't modify a read-only property.")

## The day of this date. An integer value from 1 to 31.
## [br][br]
## [b]Note[/b]: Read-only variable, use [method set_date] instead.
var day: int:
	get: return _day
	set(d): push_error("Can't modify a read-only property.")

var _year: int = 1

var _month: int = 1

var _day: int = 1


## A static function that returns a [Date] object
## with the specific date or [code]null[/code] if the date is invalid.
## [codeblock]
## var date = Datelib.get_date(2026, 5, 7)
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


## A static function that returns a [Date] object with todays date.
## The date is fetched from the system.
## [codeblock]
## var today = Datelib.get_today()
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


## Add any number of days to this date.
func add_days(days: int) -> void:
	if days < 0:
		subtract_days(-days)
		return
	_day += days
	while _day > Datelib.get_days_in_month(_year, _month):
		_day -= Datelib.get_days_in_month(_year, _month)
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
	var days_in_new_month: int = Datelib.get_days_in_month(_year, _month)
	if _day > days_in_new_month:
		_day = days_in_new_month


## Adds any number of years to the date. February 29 will be set 
## to February 28 if the new year is not a leap year.
func add_years(years: int) -> void:
	_year += years
	if _month == 2 and _day == 29 and not Datelib.is_leap_year(year):
		_day = 28


## Return the number of days between two Date objects. Is only accurate
## when dates are after the year 1582.
func days_to(date: Date) -> int:
	return (
		Datelib.get_julian_day(year, month, day) -
		Datelib.get_julian_day(date.year, date.month, date.day)
	)


## Returns a new Date object which is a copy of this Date.
func duplicate() -> Date:
	return Date.new(year, month, day)


## Returns [code]true[/code] if this Date is before the provided date, [code]false[/code] otherwise.
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


## Returns [code]true[/code] if this Date is after the provided date, [code]false[/code] otherwise.
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


## Returns [code]true[/code] if this Date is the same as the provided date, [code]false[/code] otherwise.
func is_equal(date: Date) -> bool:
	return year == date.year and month == date.month and day == date.day


## Attempt to set the year, month and day of this Date.
## [br][br]
## Returns [code]true[/code] if everything was changed,
## otherwise returns [code]false[/code] because the date was invalid.
@warning_ignore("shadowed_variable")
func set_date(year: int, month: int, day: int) -> bool:
	var previous_year := _year
	var previous_month := _month
	var previous_day := _day
	
	_year = year
	_month = month
	_day = day
	
	if not Datelib.is_valid(year, month, day):
		_year = previous_year
		_month = previous_month
		_day = previous_day
		return false
	
	return true


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
		_day += Datelib.get_days_in_month(_year, _month)


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
	var days_in_new_month: int = Datelib.get_days_in_month(_year, _month)
	if _day > days_in_new_month:
		_day = days_in_new_month


## Subtracts any number of years from the date. February 29 will be set 
## to February 28 if the new year is not a leap year.
func subtract_years(years: int) -> void:
	_year -= years
	if _month == 2 and _day == 29 and not Datelib.is_leap_year(year):
		_day = 28
