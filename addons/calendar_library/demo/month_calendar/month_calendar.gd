@tool
extends Container

signal date_toggled(toggled_on: bool, date: Calendar.Date)

@export var show_weeks: bool = true:
	set(b):
		show_weeks = b
		_is_waiting_refresh = true
		_refresh.call_deferred()

@export var year: int = Time.get_date_dict_from_system().year:
	set(y):
		year = y
		_is_waiting_refresh = true
		_refresh.call_deferred()

@export var month: int = Time.get_date_dict_from_system().month:
	set(m):
		month = m
		_is_waiting_refresh = true
		_refresh.call_deferred()

var calendar: Calendar = Calendar.new():
	set(c):
		calendar = c
		_is_waiting_refresh = true
		_refresh.call_deferred()

var button_group: ButtonGroup = ButtonGroup.new():
	set(b):
		button_group = b
		_is_waiting_refresh = true
		_refresh.call_deferred()

# Let's say that you need to change a bunch of properties in the same frame,
# each one would trigger a refresh (completely recreate the calendar).
# This variable prevents refreshs that already took in count the most up-to-date variables.
var _is_waiting_refresh: bool = false


func _refresh() -> void:
	if not _is_waiting_refresh:
		return
	
	var months_formatted = calendar.get_months_formatted(Calendar.MonthFormat.MONTH_FORMAT_FULL)
	%MonthLabel.text = months_formatted[month - 1]
	%MonthGrid.columns = 8 if show_weeks else 7
	_is_waiting_refresh = false
	
	_clear_grid()
	_insert_weekday_names()
	_insert_weeks()


func _clear_grid() -> void:
	for child in %MonthGrid.get_children():
		child.queue_free()


func _insert_weekday_names() -> void:
	var weekdays: Array[String] = calendar.get_weekdays_formatted(Calendar.WeekdayFormat.WEEKDAY_FORMAT_SHORT)
	
	# If show_weeks is true, add empty space before the weekday names.
	if show_weeks:
		%MonthGrid.add_child(Label.new())
	
	for weekday in weekdays:
		var label := Label.new()
		label.text = weekday
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size_flags_vertical = Control.SIZE_FILL
		label.size_flags_horizontal = Control.SIZE_FILL
		label.theme_type_variation = "WeekdayLabel"
		
		%MonthGrid.add_child(label)


func _insert_weeks() -> void:
	var weeks: Array = calendar.get_calendar_month(year, month, true)
	
	for week: Array in weeks:
		
		# If show_weeks is true, show the week number at the start of the week
		if show_weeks:
			var first_date: Calendar.Date = week[0]
			var week_number = calendar.get_week_number(first_date.year, first_date.month, first_date.day)
			var week_label = Label.new()
			week_label.text = str(week_number)
			week_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			week_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			week_label.size_flags_vertical = Control.SIZE_FILL
			week_label.size_flags_horizontal = Control.SIZE_FILL
			week_label.theme_type_variation = "WeekLabel"
			
			%MonthGrid.add_child(week_label)
		
		# Add each day of the week.
		for date: Calendar.Date in week:
			var button := Button.new()
			button.text = str(date.day)
			button.toggle_mode = true
			button.button_group = button_group
			button.size_flags_vertical = Control.SIZE_FILL
			button.size_flags_horizontal = Control.SIZE_FILL
			button.toggled.connect(date_toggled.emit.bind(date))
			
			if calendar.get_today().is_equal(date):
				button.theme_type_variation = "TodayButton"
			else:
				button.theme_type_variation = "DayButton"
			
			if date.month != month:
				button.disabled = true
			
			%MonthGrid.add_child(button)
