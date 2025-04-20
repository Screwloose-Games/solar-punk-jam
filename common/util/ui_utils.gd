extends RefCounted

static func add_to_screen_space_at_origin_node(origin_node: Node2D, node: Node2D, canvas_node: CanvasLayer):
    var vt = origin_node.get_canvas_transform()
    node.global_position = origin_node.global_position + vt.origin
    canvas_node.add_child.call_deferred(node)
