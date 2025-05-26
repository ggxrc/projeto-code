# /cenas/Orquestrador.gd
extends Node
	
@onready var menu_principal = $MenuPrincipal
@onready var prologue = $Prologue
@onready var tela_inicial = $Prologue/CutsceneInicial/TelaInicial

var scenes: Array
var next_scene: Node

func _ready() -> void:
	scenes = [
		menu_principal,
		prologue,
		tela_inicial
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
	tela_inicial.visible = true
	tela_inicial.MOUSE_FILTER_STOP


func _on_sair_pressed() -> void:
	get_tree().quit()
