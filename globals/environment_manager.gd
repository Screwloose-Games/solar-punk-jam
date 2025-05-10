extends Node

signal day_cycle_start()
signal day_cycle_end()
signal day_cycle_update(offset: float)
signal force_end_day()
signal UpdatedAvailableResources
signal act_updated(act_num: int)

const characters = ["Seeds","Contractor","Electrician","Craftor","Plumber"]
const resources = ["Electricity", "Water", "Food", "Waste", "Soil", "Happiness", "Materials", "Seeds", "Environment"]
# These will not be enumerated in the HUD by default since they are displayed in other ways
const hidden_resources = ["Happiness", "Environment"]

var resource_storage_limits = {"Electricity":0, "Water":0}

var current_resources = {"Happiness":10}
var daily_resources = {}
var deposited_resources = {}
var current_act: int = 1:
	set(val):
		if current_act != val:
			act_updated.emit(current_act)
			current_act = val

func add_storage_capacity(resource: String, amount: int) -> void:
	if not resource_storage_limits.has(resource):
		push_warning("Trying to add storage for an unknown resource: %s" % resource)
		return
	resource_storage_limits[resource] += amount

func set_storage_capacity(resource: String, amount: int) -> void:
	if not resource_storage_limits.has(resource):
		push_warning("Trying to set storage for an unknown resource: %s" % resource)
		return
	resource_storage_limits[resource] = amount

# Gets the current storage capacity
func get_storage_capacity(resource: String) -> int:
	if not resource_storage_limits.has(resource):
		push_warning("Trying to get storage for an unknown resource: %s" % resource)
		return 0
	return resource_storage_limits[resource]

func gain_resource(resource: String, quantity: int):
	prints("Gaining", resource, quantity, current_resources)
	if resource in current_resources:
		current_resources[resource] += quantity
	else:
		current_resources[resource] = quantity
		
		
	if resource in daily_resources:
		daily_resources[resource] += quantity
	else:
		daily_resources[resource] = quantity
		
		

	if resource in resource_storage_limits:
		if current_resources[resource] > resource_storage_limits[resource]:
			prints("We cannot store all of this resource, discarding some")
			current_resources[resource] = resource_storage_limits[resource]
		if daily_resources[resource] > resource_storage_limits[resource]:
			daily_resources[resource] = resource_storage_limits[resource]

	UpdatedAvailableResources.emit()

func gain_resources(new_resources: Dictionary[String, int]):
	for resource in new_resources:
		gain_resource(resource, new_resources[resource])
	return true

func spend_resource(resource: String, quantity: int):
	if resource in current_resources:
		current_resources[resource] -= quantity
		if current_resources[resource] < 0:
			current_resources[resource] = 0
	else:
		current_resources[resource] = 0
	UpdatedAvailableResources.emit()

func spend_resources(new_resources: Dictionary[String, int]):
	for resource in new_resources:
		spend_resource(resource, new_resources[resource])
	return true

func deposit_resource(resource: String, quantity: int):
	prints("Depositing", resource, quantity, current_resources)
	if resource in current_resources:
		deposited_resources[resource] += quantity
	else:
		deposited_resources[resource] = quantity
	UpdatedAvailableResources.emit()

func check_amount(resource: String, quantity: int):
	return has_at_least(resource, quantity)
		
func has_at_least(resource: String, quantity: int):
	if resource in current_resources:
		return current_resources[resource] >= quantity
	else:
		return false

func has_enough(required_resources: Dictionary[String, int]):
	for resource in required_resources:
		if resource in current_resources:
			if current_resources[resource] < required_resources[resource]:
				return false
	return true

func get_resource_count(resource: String):
	if resource in current_resources:
		return current_resources[resource]
	return 0

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
	signal started_raining
	signal stopped_raining
	
	var current_time_in_game_hours = 12.0
	var day_length_in_game_hours = 12.0
	var day_start_in_game_hours = 8.0
	var day_length_in_seconds = 30.0
	var night_length_in_seconds = 2.0
	var is_paused := false
	var is_daytime := true
	var is_raining: bool = false:
		set(val):
			if is_raining != val:
				if val:
					started_raining.emit()
					GlobalSignalBus.started_raining.emit()
				else:
					stopped_raining.emit()
					GlobalSignalBus.stopped_raining.emit()
			is_raining = val
			
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
