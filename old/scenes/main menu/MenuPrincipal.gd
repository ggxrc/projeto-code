extends Control

# MenuPrincipal.gd - Script para o menu principal

# Referências aos nós
@onready var start_button = $VBoxContainer/StartButton
@onready var config_button = $VBoxContainer/ConfigButton
@onready var credits_button = $VBoxContainer/CreditsButton
@onready var exit_button = $VBoxContainer/ExitButton

# Referências aos gerenciadores
var state_manager
var audio_manager

func _ready():
	# Conectar sinais dos botões
	start_button.pressed.connect(_on_start_button_pressed)
	config_button.pressed.connect(_on_config_button_pressed)
	credits_button.pressed.connect(_on_credits_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	# Obter referências aos serviços
	var service_locator = $"/root/ServiceLocator"
	state_manager = service_locator.get_service("StateManager")
	audio_manager = service_locator.get_service("AudioManager")
	
	# Tocar música do menu
	audio_manager.play_music("menu_theme", "res://assets/audio/music/menu_theme.ogg")

# Callbacks para os botões
func _on_start_button_pressed():
	audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.ogg")
	state_manager.change_state("Gameplay")

func _on_config_button_pressed():
	audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.ogg")
	# Chamar cena de configuração ou abrir painel de configuração
	pass

func _on_credits_button_pressed():
	audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.ogg")
	state_manager.change_state("Credits")

func _on_exit_button_pressed():
	audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.ogg")
	get_tree().quit()
