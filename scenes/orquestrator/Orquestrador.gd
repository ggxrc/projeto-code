# /cenas/Orquestrador.gd
extends Node
	
@onready var menu_principal = $MenuPrincipal
@onready var level_selection = $LevelSelection
@onready var prologue = $Prologue

func _on_voltar_menu_pressed() -> void:
	menu_principal.visible = true

func _on_iniciar_pressed() -> void:
	prologue.visible = true
	menu_principal.visible = false
	level_selection.visible = false
	

func _on_sair_pressed() -> void:
	get_tree().quit()
