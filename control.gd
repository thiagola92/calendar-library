extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var date := Date.get_date(2026,2,1)
	var week := Week.get_week(date, Time.WEEKDAY_MONDAY)
	
	if date:
		print(date)
		print(week)
		print(week.get_week_number(Week.WeekNumberSystem.FOUR_DAY))
		print(week.get_week_number(Week.WeekNumberSystem.TRADITIONAL))
