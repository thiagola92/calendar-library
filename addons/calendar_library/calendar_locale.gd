## A resource to define localized names for weekdays and months
##
## CalendarLocale is used by [Calendar] to represent the correct
## localized versions of weekday and month names. Create a new
## CalendarLocale resource and set the localized names in the Inspector.
## You can assign a new CalendarLocale to any [Calendar] object.
extends Resource
class_name CalendarLocale

enum NameFormat {
	## Get the weekday/month full name.
	FULL,
	## Get the weekday/month name as an abbreviated version.
	## Weekday example: "Mon" for "Monday".
	## Month example: "Jan" for "January".
	ABBR,
	## Get the weekday/month in a short form.
	## Weekday example: "M" for "Monday".
	## Month example: "J" for "January".
	SHORT,
}

## The standard date format for the locale.
## Use Calendar's [method get_date_locale_format] to get a formatted string based on
## this format.
@export_enum("Year-Month-Day", "Day-Month-Year", "Month-Day-Year", "Year-Day-Month") var date_format := 0

## Symbol dividing the year, month and day in Date Format, for example Y/M/D or D-M-Y.
## Can be any character or characters.
@export var divider_symbol := "-"

@export_category("Weekday")
@export var monday := "Monday"
@export var tuesday := "Tuesday"
@export var wednesday := "Wednesday"
@export var thursday := "Thursday"
@export var friday := "Friday"
@export var saturday := "Saturday"
@export var sunday := "Sunday"

@export_group("Weekday Abbreviation", "abbr_")
@export var abbr_monday := "Mon"
@export var abbr_tuesday := "Tue"
@export var abbr_wednesday := "Wed"
@export var abbr_thursday := "Thu"
@export var abbr_friday := "Fri"
@export var abbr_saturday := "Sat"
@export var abbr_sunday := "Sun"

@export_group("Weekday Short", "short_")
@export var short_monday := "M"
@export var short_tuesday := "T"
@export var short_wednesday := "W"
@export var short_thursday := "T"
@export var short_friday := "F"
@export var short_saturday := "S"
@export var short_sunday := "S"


@export_category("Month")
@export var january := "January"
@export var february := "February"
@export var march := "March"
@export var april := "April"
@export var may := "May"
@export var june := "June"
@export var july := "July"
@export var august := "August"
@export var september := "September"
@export var october := "October"
@export var november := "November"
@export var december := "December"

@export_group("Month Abbreviation", "abbr_")
@export var abbr_january := "Jan"
@export var abbr_february := "Feb"
@export var abbr_march := "Mar"
@export var abbr_april := "Apr"
@export var abbr_may := "May"
@export var abbr_june := "Jun"
@export var abbr_july := "Jul"
@export var abbr_august := "Aug"
@export var abbr_september := "Sep"
@export var abbr_october := "Oct"
@export var abbr_november := "Nov"
@export var abbr_december := "Dec"

@export_group("Month Short", "short_")
@export var short_january := "J"
@export var short_february := "F"
@export var short_march := "M"
@export var short_april := "A"
@export var short_may := "M"
@export var short_june := "J"
@export var short_july := "J"
@export var short_august := "A"
@export var short_september := "S"
@export var short_october := "O"
@export var short_november := "N"
@export var short_december := "D"


## Returns the name for a given month.
func get_month(month: Time.Month, format: NameFormat = NameFormat.ABBR) -> String:
	var months: Array[String] = get_months(format)
	return months[month - 1]


## Returns an array with all the month's names from "January" to "December" (follows [enum Time.Month] order).
func get_months(format: NameFormat = NameFormat.ABBR) -> Array[String]:
	var prefix: String = ""
	
	match format:
		NameFormat.FULL:
			prefix = ""
		NameFormat.ABBR:
			prefix = "abbr_"
		NameFormat.SHORT:
			prefix = "short_"
	
	var months: Array[String] = [
		get(prefix + "january"),
		get(prefix + "february"),
		get(prefix + "march"),
		get(prefix + "april"),
		get(prefix + "may"),
		get(prefix + "june"),
		get(prefix + "july"),
		get(prefix + "august"),
		get(prefix + "september"),
		get(prefix + "october"),
		get(prefix + "november"),
		get(prefix + "december"),
	]
	
	return months


## Returns the weekday name for a given date.
func get_weekday(
	weekday: Time.Weekday,
	format: CalendarLocale.NameFormat = CalendarLocale.NameFormat.FULL
) -> String:
	var weekdays: Array[String] = get_weekdays(format)
	return weekdays[weekday]


## Returns an array with all the weekday's names from "Sunday" to "Saturday".[br]
## The initial weekday can be changed through [param first].
func get_weekdays(
	format: NameFormat = NameFormat.FULL,
	first: Time.Weekday = Time.WEEKDAY_SUNDAY,
) -> Array[String]:
	var prefix: String = ""
	
	match format:
		NameFormat.FULL:
			prefix = ""
		NameFormat.ABBR:
			prefix = "abbr_"
		NameFormat.SHORT:
			prefix = "short_"
	
	var weekdays: Array[String] = [
		get(prefix + "sunday"),
		get(prefix + "monday"),
		get(prefix + "tuesday"),
		get(prefix + "wednesday"),
		get(prefix + "thursday"),
		get(prefix + "friday"),
		get(prefix + "saturday"),
	]
	
	# Finish if doesn't need to reorder.
	if first == Time.WEEKDAY_SUNDAY:
		return weekdays
	
	var reordered: Array[String] = []
	
	for i in range(7):
		var index: int = (first + i) % 7
		reordered.append(weekdays[index])
	
	return reordered
