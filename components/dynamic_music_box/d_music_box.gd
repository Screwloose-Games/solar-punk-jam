extends Area3D
class_name DynamicMusicRegion

    
@export var region_id: String
@export var track_idx: int 

    
func _ready():
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    DynamicMusic.track_region_entered.connect(_on_track_region_entered)
    DynamicMusic.track_region_exited.connect(_on_track_region_exited)
    
    DynamicMusic.play()
    
    var d_stream_count: int = DynamicMusic.stream.stream_count  
    
    for stream_idx in d_stream_count:
        if stream_idx == 0:
            continue
        DynamicMusic.stop_stream(stream_idx)
        
    print("DynamicMusicRegion ready")

func _on_body_exited(body:Node3D) -> void:
    if body.name == "Player":
        DynamicMusic.track_region_exited.emit(track_idx)


func _on_body_entered(body:Node3D) -> void:
    if body.name == "Player":
        DynamicMusic.track_region_entered.emit(track_idx)


func _on_track_region_entered(DM_track_idx):
    DynamicMusic.play_stream(DM_track_idx, 0)

    
func _on_track_region_exited(DM_track_idx):
    DynamicMusic.stop_stream(DM_track_idx)