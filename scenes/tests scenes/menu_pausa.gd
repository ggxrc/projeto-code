extends CanvasLayer

@export var menu_visible : Color
@export var menu_invisible : Color
@export var mouse_filter : Control

var pause_button = Input.is_action_just_pressed("pausa")
var fade_in_effect : Tween
var fade_out_effect : Tween

func fade_in():
	fade_in_effect = get_tree().create_tween()
	fade_in_effect.tween_property(self, "modulate", menu_invisible, 0.5)

func fade_out():
	fade_out_effect = get_tree().create_tween()
	fade_out_effect.tween_property(self, "modulate", menu_invisible, 0.5)

func paused():
	if pause_button:
		fade_in()
		mouse_filter.set_mouse_filter(Control.MOUSE_FILTER_STOP)

func _on_retomar_pressed() -> void:
	fade_out()

func _on_control_gui_input(event: InputEvent) -> void:
	paused()
