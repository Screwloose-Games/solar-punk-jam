extends Node

func has_component(component) -> bool:
    if component:
        return true

    return false

func set_component_property(component, property: String, value, deferred: bool = true) -> void:
    var defer: String = " "

    if has_component(component) and property in component:
        if deferred: 
            defer = "deferred"
            component.set_deferred(property, value)
        else:
            component.set(property, value)
    
        print("ComponentUtils: set " + defer + " value: " + str(value) + " on property " + property + " in component " + str(component))

func compile_warnings(properties: Array, warning_strings: Array) -> PackedStringArray:
    var warnings: PackedStringArray = PackedStringArray()
    var i: int = 0
    for property in properties:
        if not property:
            warnings.append(warning_strings[i])
            i += 1 
    return warnings
