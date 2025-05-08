extends AudioStreamPlayer3D
class_name SoundPlayer3D

@export_group("Start SFX condition")
@export var start_callable_node: Node = null
@export var start_signal_name: StringName = ""
@export_group("Stop SFX condition")
@export var stop_callable_node: Node = null
@export var stop_signal_name: StringName = ""
@export_group("Global SFX condition")
@export var g_start_signal_name: StringName = ""
@export var g_stop_signal_name: StringName = ""

@onready var global_signal_bus: Node = get_tree().get_root().get_node("GlobalSignalBus")

var try_connect_start_result: int = FAILED
var try_connect_stop_result: int = FAILED
var try_connect_g_start_result: int = FAILED
var try_connect_g_stop_result: int = FAILED

# extends: https://docs.godotengine.org/en/stable/classes/class_@globalscope.html#enum-globalscope-error
enum TryConnectError {
    INSTANCE_INVALID = 49,
    NO_SIGNAL_NAME = 50,
    NO_MATCHING_SIGNAL_NAME = 51,
}
    

func _ready() -> void:
    try_connect_stop_signal()
    try_connect_start_signal()
    try_connect_global_start_signal()
    try_connect_global_stop_signal()


func try_connect_stop_signal() -> int:
    if not is_instance_valid(stop_callable_node):
        try_connect_stop_result = TryConnectError.INSTANCE_INVALID
        return TryConnectError.INSTANCE_INVALID
        
    if stop_signal_name == "":
        try_connect_stop_result = TryConnectError.NO_SIGNAL_NAME
        return TryConnectError.NO_SIGNAL_NAME
        
    if not stop_callable_node.has_signal(stop_signal_name):
        try_connect_stop_result = TryConnectError.NO_MATCHING_SIGNAL_NAME
        return TryConnectError.NO_MATCHING_SIGNAL_NAME
    
    try_connect_stop_result = stop_callable_node.connect(stop_signal_name, _on_stop)    
    return try_connect_stop_result 
    
    
func try_connect_start_signal() -> bool:    
    if not is_instance_valid(start_callable_node):
        try_connect_start_result = TryConnectError.INSTANCE_INVALID
        return TryConnectError.INSTANCE_INVALID
        
    if start_signal_name == "":
        try_connect_start_result = TryConnectError.NO_SIGNAL_NAME
        return TryConnectError.NO_SIGNAL_NAME
        
    if not start_callable_node.has_signal(start_signal_name):
        try_connect_start_result = TryConnectError.NO_MATCHING_SIGNAL_NAME
        return TryConnectError.NO_MATCHING_SIGNAL_NAME
        
    try_connect_start_result = start_callable_node.connect(start_signal_name, _on_start)
    return try_connect_start_result 


func try_connect_global_start_signal() -> int:
    if not is_instance_valid(global_signal_bus):
        try_connect_g_start_result = TryConnectError.INSTANCE_INVALID
        return TryConnectError.INSTANCE_INVALID
        
    if g_start_signal_name == "":
        try_connect_g_start_result = TryConnectError.NO_SIGNAL_NAME
        return TryConnectError.NO_SIGNAL_NAME
        
    if not global_signal_bus.has_signal(g_start_signal_name):
        try_connect_g_start_result = TryConnectError.NO_MATCHING_SIGNAL_NAME
        return TryConnectError.NO_MATCHING_SIGNAL_NAME
    
    try_connect_g_start_result = global_signal_bus.connect(g_start_signal_name, _on_start)
    return try_connect_g_start_result 


func try_connect_global_stop_signal() -> int:
    if not is_instance_valid(global_signal_bus):
        try_connect_g_stop_result = TryConnectError.INSTANCE_INVALID
        return TryConnectError.INSTANCE_INVALID
    
    if g_start_signal_name == "":
        try_connect_g_stop_result = TryConnectError.NO_SIGNAL_NAME
        return TryConnectError.NO_SIGNAL_NAME
    
    if not global_signal_bus.has_signal(g_stop_signal_name):
        try_connect_g_stop_result = TryConnectError.NO_MATCHING_SIGNAL_NAME
        return TryConnectError.NO_MATCHING_SIGNAL_NAME
        
    try_connect_g_stop_result = global_signal_bus.connect(g_stop_signal_name, _on_stop)
    return try_connect_g_stop_result 


func _on_start() -> void:
    play()
    

func _on_stop() -> void:
    stop()