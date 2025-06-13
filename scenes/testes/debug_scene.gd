extends Node

@onready var dialogue_ui = $DialogueBoxUI
@onready var description_ui = $DescriptionBoxUI

# Testes do sistema
var test_doors = true  # Definir como true para testar o sistema de portas interativas

func _ready():
	if test_doors:
		# Carrega o script de teste de portas
		var door_test = Node.new()
		door_test.name = "DoorTest"
		door_test.set_script(load("res://scenes/testes/debug_door_test.gd"))
		add_child(door_test)
		print("Teste do sistema de portas interativas iniciado")
	else:
		# Testes originais de diálogo
		await get_tree().create_timer(1.0).timeout
		dialogue_ui.show_line("Este é um teste da caixa de cima!")
		await get_tree().create_timer(1.0).timeout
		description_ui.show_description("Este é um teste da caixa de baixo!")
