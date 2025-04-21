extends Node2D

var world_data_cache = []
@onready var community := CommunityModel.new()
var current = null

class EnvironmentalModel:
	var ticks: int = 0
	var hour: int = 0
	var day: int = 0
	var sunlight: float = 0.0
	var clouds: float = 0.0
	var rainfall: float = 0.0
	var windspeed: float = 0.0
	func _init():
		pass
	func update(ticks_):
		ticks = ticks_
		hour = ticks % 24
		day = ticks / 24
		# day/night cycle
		sunlight = max(0.0, sin(PI/12*ticks-PI*0.5))
		windspeed = max(0.0, (1.0+sin(PI/6*ticks))*0.5)
		clouds = max(0.0, -0.2+sin(3 * PI*ticks/24)+0.6*sin(2*PI*ticks/24))
		rainfall = max(0.0,(clouds-0.5))*2
		sunlight = max(0.0, sunlight - clouds)
	func as_array():
		return [ticks, day, hour, sunlight, clouds, rainfall, windspeed]
	func features():
		return [rainfall, sunlight, windspeed]
	func as_text():
		return "Tick: %s Day: %s Hour: %s Sunlight: %.2f Clouds: %.2f Rain: %.2f Wind: %.2f" % self.as_array()

class ResourceStats:
	var electricity: float = 0.0
	var water: float = 0.0
	var food: float = 0.0
	var materials: float = 0.0
	var trash: float = 0.0
	var wellness: float = 0.0
	func _init(e,w,f,m,t,h):
		self.electricity = e
		self.water = w
		self.food = f
		self.materials = m
		self.trash = t
		self.wellness = h
	static func new_empty() -> ResourceStats:
		return ResourceStats.new(0.0,0.0,0.0,0.0,0.0,0.0)
	static func new_identity() -> ResourceStats:
		return ResourceStats.new(1.0,1.0,1.0,1.0,1.0,1.0)
	static func from_array(a):
		return ResourceStats.new(a[0], a[1], a[2], a[3], a[4], a[5])
	static func from_record(a):
		return ResourceStats.new(a[1], a[2], a[3], a[4], a[5], a[6])
	func as_array():
		return [electricity, water, food, materials, trash, wellness]
	func overwrite_from_array(a):
		electricity = a[0]
		water=a[1]
		food=a[2]
		materials=a[3]
		trash=a[4]
		wellness=a[5]
	func clone():
		return ResourceStats.new(electricity, water, food, materials, trash, wellness)
	func accumulate(d: ResourceStats, delta:=1.0):
		electricity+=d.electricity*delta
		water+=d.water*delta
		food+=d.food*delta
		materials+=d.materials*delta
		trash+=d.trash*delta
		wellness+=d.wellness*delta
	func multiply(d: ResourceStats, delta:=1.0):
		electricity*=d.electricity*delta
		water*=d.water*delta
		food*=d.food*delta
		materials*=d.materials*delta
		trash*=d.trash*delta
		wellness*=d.wellness*delta
	func store_with_limit(d: ResourceStats, l:ResourceStats, delta:=1.0):
		var excess = [0.0,0.0,0.0,0.0,0.0,0.0]
		self.accumulate(d, delta)
		var accumulated = self.as_array()
		var limits = l.as_array()
		for idx in 6:
			if limits[idx]>=0 and accumulated[idx]>limits[idx]:
				excess[idx] = accumulated[idx] - limits[idx]
				accumulated[idx] = limits[idx]
			accumulated[idx] = max(0.0, accumulated[idx])
		self.overwrite_from_array(accumulated)
		return ResourceStats.from_array(excess)			
		
	func as_text():
		return "<%s %s %s %s %s %s>" % self.as_array()
	func as_rtf():
		var rtf = ""
		rtf += "[table=6]"
		rtf += "[cell][color=#fbf236]%.2f[/color][/cell]" % electricity
		rtf += "[cell][color=#639bff]%.2f[/color][/cell]" % water
		rtf += "[cell][color=#99e550]%.2f[/color][/cell]" % food
		rtf += "[cell][color=#8f563b]%.2f[/color][/cell]" % materials
		rtf += "[cell][color=#a6a6a6]%.2f[/color][/cell]" % trash
		rtf += "[cell][color=#d95763]%.2f[/color][/cell]" % wellness
		rtf += "[/table]"
		return rtf

class CharacterModel:
	var record: String
	var stats: ResourceStats
	var strength := 0.0
	func _init(record_, strength_, buffs_array):
		record = record_
		strength = strength_
		stats = ResourceStats.from_array(buffs_array)

class Prop:
	var coords: Vector2
	var record: Array
	var stats: ResourceStats 
	func _init(coords_, record_, stats_):
		coords = coords_
		record = record_
		stats = stats_

class CommunityModel:
	var ticks := 0
	var stats_current := ResourceStats.new_empty()
	var stats_current_rate := ResourceStats.new_empty()
	var stats_current_storage_capacity := ResourceStats.new_empty()
	var stats_current_storage_stored := ResourceStats.new_empty()
	var stats_current_waste := ResourceStats.new_empty()
	var stats_current_waste_rate := ResourceStats.new_empty()
	var stats_current_character_buffs := ResourceStats.new_empty()
	var environment := EnvironmentalModel.new()
	var props = []
	var characters = []
	func _init():
		pass

	func build_prop(record: Array, coords: Vector2):
		var stats = ResourceStats.from_record(record)
		props.append(Prop.new(coords, record, stats))
		
	func add_character(character):
		self.characters.append(character)
		
	func get_character_names_as_text():
		var names = []
		for i in self.characters:
			names.append(i.record)
		return ", ".join(names)
	
	
	func update_stats_rate():
		prints("update_stats_rate")
		stats_current_rate = ResourceStats.new_empty()
		stats_current_storage_capacity = ResourceStats.new_empty()
		stats_current_storage_capacity.wellness = -1
		stats_current_character_buffs = ResourceStats.new_identity()
		var stats_buffs = stats_current_character_buffs.as_array()
		for character in self.characters:
			var stats__ = character.stats.as_array()
			for idx in len(stats_buffs):
				stats_buffs[idx] *= stats__[idx]
		stats_current_character_buffs.overwrite_from_array(stats_buffs)
			
			
			
		for prop in self.props:
				if prop.record[7]>0:
					#prints("found storage", prop.record[0], prop.stats)
					# TODO decide how to encode this
					match prop.record[0]:
						"Battery":
							stats_current_storage_capacity.electricity = 100
						"Water tank":
							stats_current_storage_capacity.water = 100
						"Pantry":
							stats_current_storage_capacity.food = 100
						"Garbage dump":
							stats_current_storage_capacity.materials = 100
				else:
					var stats_ = prop.stats.as_array()
					# Apply environment model first
					var env_features = environment.features()
					for idx2 in len(env_features):
						if prop.record[8+idx2*2] != 1.0 or prop.record[8+idx2*2+1] != 1.0:
							var multiplier = lerp(prop.record[8+idx2*2+1], prop.record[8+idx2*2], env_features[idx2])
							for idx3 in len(stats_):
								stats_[idx3] *= multiplier
					# TODO accumulate positive and negative separately and apply character model buffs?
					
					
					
					# Check if there is enough supply before considering an item
					var stats_current_rate_ = stats_current_rate.as_array()
					var stats_current_storage_ = stats_current_storage_stored.as_array()
					var can_run = true
					for idx3 in len(stats_):
						if stats_[idx3] < 0.0 and not (stats_[idx3] + stats_current_rate_[idx3] + stats_current_storage_[idx3]) > 0.0:
							prints("cannot run", prop.record[0], "because of not enough", idx3, "producing", stats_current_rate_[idx3], "stored", stats_current_storage_[idx3], "required", stats_[idx3])
							can_run = false
							break
					if can_run:
						# TODO allow for partial resource?
						prints("running resource",prop.record[0], prop.stats)
						stats_current_rate.accumulate(ResourceStats.from_array(stats_))
		
	func update_stats_tick(delta: float):
		# TODO consider partial ticks?
		self.ticks += 1
		self.environment.update(self.ticks)
		self.update_stats_rate()
		stats_current.accumulate(stats_current_rate, delta)
		stats_current_waste_rate = stats_current_storage_stored.store_with_limit(stats_current_rate, stats_current_storage_capacity, delta)
		stats_current_waste.accumulate(stats_current_waste_rate)

func update_stats_tick(delta):
	community.update_stats_tick(delta)
	$CanvasLayer/VBoxContainer/RateStats.text = "Environment:\n" + community.environment.as_text()
	#$CanvasLayer/VBoxContainer/RateStats.bbcode_text += "\nTotal:" + community.stats_current.as_rtf()
	$CanvasLayer/VBoxContainer/RateStats.text += "\nStorage capacity:" + community.stats_current_storage_capacity.as_rtf()
	$CanvasLayer/VBoxContainer/RateStats.text += "\nIn storage:" + community.stats_current_storage_stored.as_rtf()
	$CanvasLayer/VBoxContainer/RateStats.text += "\nWasted:" + community.stats_current_waste.as_rtf()
	$CanvasLayer/VBoxContainer/RateStats.text += "\nCharacters:\n" + community.get_character_names_as_text()
	$CanvasLayer/VBoxContainer/RateStats.text += "\nCharacter buffs:" + community.stats_current_character_buffs.as_rtf()
	$CanvasLayer/VBoxContainer/RateStats.text += "\nGeneration rate:" + community.stats_current_rate.as_rtf()
	$CanvasLayer/VBoxContainer/RateStats.text += "\nWaste rate:" + community.stats_current_waste_rate.as_rtf()


func _ready():
	world_data_cache = get_world_data()
	community.update_stats_rate()
	interval_update_change(1.0)
	build_community_from_tilemap(community, $TileMap)
	community.add_character(CharacterModel.new("Electrician", 1.0, [1.25,1,1,1,1,1]))
	community.add_character(CharacterModel.new("Farmer", 1.0, [1,1,1.25,1,1,1]))
	#interval_update(1)
	$CanvasLayer/VBoxContainer/HBoxContainer/Button1.connect("pressed", self.interval_update_change.bind(0.0))
	$CanvasLayer/VBoxContainer/HBoxContainer/Button2.connect("pressed", self.interval_update_change.bind(1.0))
	$CanvasLayer/VBoxContainer/HBoxContainer/Button3.connect("pressed", self.interval_update_change.bind(0.1))
	

func interval_update_change(delay):
	if interval_update_delay == 0.0:
		call_deferred("interval_update")
	interval_update_delay = delay
	

var interval_update_delay = 0.0
func interval_update():
	if interval_update_delay > 0.0:
		update_stats_tick(1.0)
		var tween = create_tween()
		tween.tween_callback(interval_update).set_delay(interval_update_delay)
	
func build_community_from_tilemap(community: CommunityModel, tilemap: TileMap):
	for i in tilemap.get_used_cells(0):
		var idx_ := tilemap.get_cell_atlas_coords(0, i)
		var idx = idx_.x + idx_.y * 8
		if idx >= 0 and idx < len(world_data_cache):
			var record = world_data_cache[idx]
			community.build_prop(record, i)

enum GAME_STATE {SELECTION, PALETTE}

static func get_world_data():
	var data_ = """Solar panel	4							0.25	1	1	0	1	1
Wind turbine	1							1	1	1	1	1.25	0.25
Bioreactor	1				-1			1	1	1	1	1	1
Flying turbine	1.5	0.5						1	1	1	1	1.5	0.5
								1	1	1	1	1	1
								1	1	1	1	1	1
Tidal power	1.5							1	1	1	1	1	1
Battery							100	1	1	1	1	1	1
Rain collection		1						1	0	1	1	1	1
Well	-0.25	1						1	0.5	1	1	1	1
Wastewater treatment	-0.5	0.5			-1			1	1	1	1	1	1
								1	1	1	1	1	1
								1	1	1	1	1	1
								1	1	1	1	1	1
Desalination	-1	1						1	1	1	1	1	1
Water tank							100	1	1	1	1	1	1
Gardening		-1	1					1.25	0.75	1	1	1	1
Vertical Hydroponics	-0.5	-0.5	1.25					1	1	1	1	1	1
Aquaponics		-1	1.5					1	1	1.25	0.75	1	1
Composting and regenerative agriculture		-0.25	1.5		-1			1	1	1	1	1	1
Fermentation			0.5		-0.25			1	1	1	1	1	1
								1	1	1	1	1	1
Seaweed farm			1.5					1	1	1	1	1	1
Pantry	-0.5						200	1	1	1	1	1	1
Hygiene		-0.75			1	2		1	1	1	1	1	1
Kitchen			-1		1	2		1	1	1	1	1	1
Housing	-0.75				1	2		1	1	1	1	1	1
								1	1	1	1	1	1
								1	1	1	1	1	1
								1	1	1	1	1	1
Floating housing	-0.25	-0.25	-1		1	2		1	1	1	1	1	1
								1	1	1	1	1	1
Timber workshop				2				1	1	1	1	1	1
Recylcing station	-0.25	-0.25		2	-2			1	1	1	1	1	1
													
													
								1	1	1	1	1	1
								1	1	1	1	1	1
Driftwood workshop				2				1	1	1	1	1	1
Garbage dump				1			200	1	1	1	1	1	1"""

	var data = data_.split("\n")
	data = Array(data)
	for i in len(data):
		data[i] = data[i].split("\t")
		data[i] = Array(data[i])
		for j in 13:
			data[i][j+1] = float(data[i][j+1])
	return data
