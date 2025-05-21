# /cenas/Orquestrador.gd
extends Node
	
@onready var menu_principal = $MenuPrincipal
@onready var level_selection = $LevelSelection
@onready var prologue = $Prologue

var scenes: Array
var next_scene: Node

func _ready() -> void:
	scenes = [
		menu_principal,
		level_selection,
		prologue
	]
	_hide_all_scenes()
	menu_principal.visible = true
	

func _hide_all_scenes() -> void:
	for scene in scenes:
		scene.visible = false
	
func scene_transition(next_scene: Node) -> void:
	_hide_all_scenes()
	next_scene.visible = true
	self.next_scene = next_scene 

func _on_voltar_menu_pressed() -> void:
	scene_transition(menu_principal)

func _on_iniciar_pressed() -> void:
	scene_transition(prologue)
	

func _on_sair_pressed() -> void:
	get_tree().quit()
