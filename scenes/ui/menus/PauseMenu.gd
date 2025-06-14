extends Control

# PauseMenu.gd - Script para o menu de pausa

# Referências aos botões
@onready var resume_button = $CenterContainer/VBoxContainer/ResumeButton
@onready var config_button = $CenterContainer/VBoxContainer/ConfigButton
@onready var main_menu_button = $CenterContainer/VBoxContainer/MainMenuButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton

# Referências aos gerenciadores
var state_manager
var audio_manager
var previous_state

func _ready():
	# Conectar sinais dos botões
	resume_button.pressed.connect(_on_resume_pressed)
	config_button.pressed.connect(_on_config_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Obter referências aos serviços
	var service_locator = $"/root/ServiceLocator"
	if service_locator:
		state_manager = service_locator.get_service("StateManager")
		audio_manager = service_locator.get_service("AudioManager")
	
	# Configurar foco inicial
	resume_button.grab_focus()

# Não precisamos mais capturar tecla ESC em um jogo mobile

# Configurar o estado anterior (para poder retornar quando despausar)
func set_previous_state(state):
	previous_state = state

# Callbacks dos botões
func _on_resume_pressed():
	if audio_manager:
		audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.ogg")
	
	# Voltar ao estado anterior
	if state_manager and previous_state:
		state_manager.change_state(previous_state)
		get_tree().paused = false
	else:
		push_error("Não foi possível retornar ao estado anterior!")
		get_tree().paused = false

func _on_config_pressed():
	if audio_manager:
		audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.ogg")
	
	# Abrir configurações
	if state_manager:
		state_manager.change_state("Config")
	else:
		push_error("StateManager não encontrado!")

func _on_main_menu_pressed():
	if audio_manager:
		audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.ogg")
	
	# Voltar ao menu principal
	get_tree().paused = false
	if state_manager:
		state_manager.change_state("MainMenu")
	else:
		push_error("StateManager não encontrado!")

func _on_quit_pressed():
	if audio_manager:
		audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.ogg")
	
	# Sair do jogo
	get_tree().quit()
