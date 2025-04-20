class_name OSUtils

static func supports_touch():
    return DisplayServer.is_touchscreen_available()

static func show_virtual_keyboard(current_text: String = ""):
    DisplayServer.virtual_keyboard_show(current_text)

## Show virtual keybaord when touching an input field
static func handle_text_input_text_focus(current_text: String = ""):
    if supports_touch():
        show_virtual_keyboard(current_text)

static func handle_text_input_event(event: InputEvent):
    if event is InputEventScreenTouch:
        show_virtual_keyboard()

#match OS.get_name():
    #"Windows":
        #print("Windows")
    #"macOS":
        #print("macOS")
    #"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
        #print("Linux/BSD")
    #"Android":
        #print("Android")
    #"iOS":
        #print("iOS")
    #"Web":
        #print("Web")

