@tool
extends PanelContainer

var locales: Dictionary[String, String] = {
	"English": "res://addons/calendar_library/demo/locales/locale_EN.tres",
	"German": "res://addons/calendar_library/demo/locales/locale_DE.tres",
	"Spanish": "res://addons/calendar_library/demo/locales/locale_ES.tres",
	"Simplified Chinese": "res://addons/calendar_library/demo/locales/locale_CN.tres",
	"Swedish": "res://addons/calendar_library/demo/locales/locale_SE.tres",
}


func _ready() -> void:
	%YearLabel.text = str(%YearCalendar.year)
	
	_setup_language_button()
	_setup_date_label()


func _setup_language_button() -> void:
	%LanguageButton.clear()
	
	for language in locales:
		%LanguageButton.add_item(language)


func _setup_date_label(date: Date = null) -> void:
	var calendar: Calendar = %YearCalendar.calendar
	
	date = date if date else calendar.get_today()
	%DateLabel.text = calendar.get_date_formatted(date.year, date.month, date.day, "%A, %-d %B")


func _on_previous_button_pressed() -> void:
	%YearCalendar.year -= 1
	%YearLabel.text = str(%YearCalendar.year)


func _on_next_button_pressed() -> void:
	%YearCalendar.year += 1
	%YearLabel.text = str(%YearCalendar.year)


func _on_show_week_button_toggled(toggled_on: bool) -> void:
	%YearCalendar.show_weeks = toggled_on


func _on_language_button_item_selected(index: int) -> void:
	var calendar: Calendar = %YearCalendar.calendar
	
	calendar.set_calendar_locale(locales.values()[index])
	%YearCalendar.refresh()


func _on_weekday_button_item_selected(index: int) -> void:
	var calendar: Calendar = %YearCalendar.calendar
	
	calendar.set_first_weekday(index + 1)
	%YearCalendar.refresh()


func _on_year_calendar_date_toggled(toggled_on: bool, date: RefCounted) -> void:
	_setup_date_label(date if toggled_on else null)


func _on_week_number_button_item_selected(index: int) -> void:
	var calendar: Calendar = %YearCalendar.calendar
	
	calendar.set_week_number_system(index)
	%YearCalendar.refresh()
