# /cenas/Orquestrador.gd
extends Node

@onready var menu_principal = $MenuPrincipal
@onready var level_selection = $LevelSelection

func _on_voltar_menu_pressed() -> void:
	menu_principal.visible = true


func _on_iniciar_pressed() -> void:
	menu_principal.visible = false
