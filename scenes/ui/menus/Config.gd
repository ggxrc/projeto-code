extends Control

# config.gd - Script para as configurações do jogo

# Referências aos elementos da interface
@onready var fullscreen_checkbox = $TabContainer/Geral/VBoxContainer/FullscreenOption/FullscreenCheckbox
@onready var master_slider = $TabContainer/Áudio/VBoxContainer/MasterVolume/MasterSlider
@onready var music_slider = $TabContainer/Áudio/VBoxContainer/MusicVolume/MusicSlider
@onready var sfx_slider = $TabContainer/Áudio/VBoxContainer/SFXVolume/SFXSlider
@onready var back_button = $BackButton

# Referências aos gerenciadores
var state_manager
var audio_manager

func _ready():
	# Conectar sinais
	back_button.pressed.connect(_on_back_button_pressed)
	fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	
	# Obter referências aos serviços
	var service_locator = $"/root/ServiceLocator"
	state_manager = service_locator.get_service("StateManager")
	audio_manager = service_locator.get_service("AudioManager")
	
	# Inicializar valores das configurações
	_load_settings()

# Carregar configurações salvas
func _load_settings():
	# Aqui seria implementada a lógica para carregar configurações de um arquivo
	# Por enquanto, apenas configuramos valores padrão
	
	# Fullscreen
	var is_fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen_checkbox.button_pressed = is_fullscreen
	
	# Volumes de áudio
	if audio_manager:
		master_slider.value = audio_manager.get_bus_volume("Master")
		music_slider.value = audio_manager.get_bus_volume("Music")
		sfx_slider.value = audio_manager.get_bus_volume("SFX")

# Salvar configurações
func _save_settings():
	# Aqui seria implementada a lógica para salvar configurações em um arquivo
	pass

# Callbacks
func _on_back_button_pressed():
	_save_settings()
	if audio_manager:
		audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.ogg")
	state_manager.change_state("MainMenu")

func _on_fullscreen_toggled(is_on):
	if is_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if audio_manager:
		audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.ogg")

func _on_master_volume_changed(value):
	if audio_manager:
		audio_manager.set_bus_volume("Master", value)

func _on_music_volume_changed(value):
	if audio_manager:
		audio_manager.set_bus_volume("Music", value)

func _on_sfx_volume_changed(value):
	if audio_manager:
		audio_manager.set_bus_volume("SFX", value)
