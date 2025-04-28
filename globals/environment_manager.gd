extends Node

signal day_cycle_start()
signal day_cycle_end()
signal day_cycle_update(offset: float)
signal force_end_day()
signal UpdatedAvailableResources

const characters = ["Seeds","Contractor","Electrician","Craftor","Plumber"]
const resources = ["Electricity", "Water", "Food", "Waste", "Soil", "Happiness", "Materials", "Seeds"]

var current_resources = {}

func gain_resource(resource: String, quantity: int):
	prints("Gaining", resource, quantity, current_resources)
	if resource in current_resources:
		current_resources[resource] += quantity
	else:
		current_resources[resource] = quantity
	UpdatedAvailableResources.emit()

func check_amount(resource: String, quantity: int):
	if resource in current_resources:
		return current_resources[resource] >= quantity
	else:
		return false


func end_day():
	force_end_day.emit()

enum TimeIcon {MORNING, MIDDAY, AFTERNOON, NIGHT}

class TimeStruct:
	var day: int
	var hour: int
	var minute: int
	var is_pm: bool
	var icon: TimeIcon
	func _init(day, hour, minute, is_pm, icon) -> void:
		self.day = day
		self.hour = hour 
		self.minute = minute
		self.is_pm = is_pm
		self.icon = icon
	

class EnvironmentModel:
	var current_time_in_game_hours = 12.0
	var day_length_in_game_hours = 12.0
	var day_start_in_game_hours = 8.0
	var day_length_in_seconds = 30.0
	var night_length_in_seconds = 2.0
	var is_paused := false
	var is_daytime := true
	var is_raining := false
	var rain_period = 5
	var day := 0
	var offset: float
	func update(current_time_in_game_hours, day_length_in_game_hours, day_start_in_game_hours, day_length_in_seconds, night_length_in_seconds, is_paused) -> void:
		self.current_time_in_game_hours = current_time_in_game_hours
		self.day_length_in_game_hours = day_length_in_game_hours
		self.day_start_in_game_hours = day_start_in_game_hours
		self.day_length_in_seconds = day_length_in_seconds
		self.night_length_in_seconds = night_length_in_seconds
		self.is_daytime = current_time_in_game_hours > day_start_in_game_hours
	func set_daytime():
		day += 1
		self.is_daytime = true
		self.is_raining = day % rain_period == (rain_period-1)
	func set_nighttime():
		self.is_daytime = false
	func set_offset(offset: float):
		self.offset = offset
	func get_in_game_time() -> TimeStruct:
		var hour = day_start_in_game_hours
		if is_daytime:
			hour += day_length_in_game_hours * offset
		else:
			hour += day_length_in_game_hours + (24 - day_length_in_game_hours) * offset
		var is_pm = false
		if hour > 12.0:
			is_pm = true
		if hour > 24.0:
			is_pm = false
		var minute = hour - floor(hour)
		var hour_ = int(hour) % 12
		if hour_ == 0:
			hour_ = 12
		return TimeStruct.new(day, hour_, int(minute*60), is_pm, TimeIcon.MIDDAY)
		
var environment_model: EnvironmentModel

func _ready() -> void:
	environment_model = EnvironmentModel.new()
	self.day_cycle_update.connect(self.environment_model.set_offset)
	self.day_cycle_start.connect(self.environment_model.set_daytime)
	self.day_cycle_end.connect(self.environment_model.set_nighttime)
	
