extends Node

@onready var dialogue_ui = $DialogueBoxUI
@onready var description_ui = $DescriptionBoxUI
func _ready():
	await get_tree().create_timer(1.0).timeout #
	dialogue_ui.show_line("Este é um teste da caixa de cima!")
	await get_tree().create_timer(1.0).timeout #
	description_ui.show_description("Este é um teste da caixa de baixo!")
