@tool
extends Container

signal date_toggled(toggled_on: bool, date: Date)

const MonthCalendar: GDScript = preload("res://addons/calendar_library/demo/month_calendar/month_calendar.gd")

@export var show_weeks: bool = true:
	set(b):
		show_weeks = b
		refresh()

@export var year: int = Time.get_date_dict_from_system().year:
	set(y):
		year = y
		refresh()

var calendar: Calendar = Calendar.new():
	set(c):
		calendar = c
		refresh()

var _button_group: ButtonGroup = ButtonGroup.new()

# Let's say that you need to change a bunch of properties in the same frame,
# each one would trigger a refresh (completely recreate the calendar).
# This variable prevents refreshs that already took in count the most up-to-date variables.
var _is_waiting_refresh: bool = false


func _ready() -> void:
	_button_group.allow_unpress = true
	
	for i in 12:
		var month_calendar := get_child(i) as MonthCalendar
		
		# Setup once and never again.
		month_calendar.button_group = _button_group
		month_calendar.month = i + 1
		month_calendar.date_toggled.connect(date_toggled.emit)
		
		# It can be changed by the user later.
		month_calendar.calendar = calendar
		month_calendar.year = year
		month_calendar.show_weeks = show_weeks


# Modifying some properties will automatically trigger refresh(),
# but modifying properties of a property will require to force a refresh().
func refresh() -> void:
	_is_waiting_refresh = true
	_refresh.call_deferred()


func _refresh() -> void:
	if not _is_waiting_refresh:
		return
	
	_is_waiting_refresh = false
	
	for month_calendar: MonthCalendar in get_children():
		month_calendar.calendar = calendar
		month_calendar.year = year
		month_calendar.show_weeks = show_weeks
