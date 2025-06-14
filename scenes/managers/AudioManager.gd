extends Node
# AudioManager.gd
# Sistema central de gerenciamento de áudio para todo o jogo

signal music_started(track_name)
signal music_stopped(track_name)
signal sound_played(sound_name)

# Configurações
@export var master_volume: float = 1.0
@export var music_volume: float = 0.8
@export var sfx_volume: float = 1.0
@export var voice_volume: float = 1.0
@export var ui_volume: float = 0.7
@export var ambient_volume: float = 0.6

# Canais de áudio
var music_players = {}
var sfx_players = {}
var voice_players = {}
var ui_players = {}
var ambient_players = {}

# Mixer buses
const MASTER_BUS = "Master"
const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"
const VOICE_BUS = "Voice"
const UI_BUS = "UI"
const AMBIENT_BUS = "Ambient"

# Cache de sons pré-carregados
var sound_cache = {}

# Reprodução atual
var current_music: String = ""
var current_ambient: String = ""
var crossfade_duration: float = 2.0

# Estado
var initialized: bool = false

# Inicialização
func _ready() -> void:
	_setup_audio_system()

# Configura o sistema de áudio
func _setup_audio_system() -> void:
	print("AudioManager: Inicializando sistema de áudio...")
	
	# Verifica se os buses de áudio existem, se não, cria
	_ensure_audio_bus_setup()
	
	# Configura os volumes iniciais
	_apply_volume_settings()
	
	# Configura os players de áudio
	_setup_audio_players()
	
	initialized = true
	print("AudioManager: Sistema de áudio inicializado.")

# Garante que os buses de áudio estão configurados corretamente
func _ensure_audio_bus_setup() -> void:
	var bus_index_master = AudioServer.get_bus_index(MASTER_BUS)
	if bus_index_master < 0:
		push_error("AudioManager: Bus Master não encontrado!")
	
	# Verificar e criar buses se necessário
	_create_bus_if_not_exists(MUSIC_BUS)
	_create_bus_if_not_exists(SFX_BUS)
	_create_bus_if_not_exists(VOICE_BUS)
	_create_bus_if_not_exists(UI_BUS)
	_create_bus_if_not_exists(AMBIENT_BUS)

# Cria um bus de áudio se ele não existir
func _create_bus_if_not_exists(bus_name: String) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		print("AudioManager: Criando bus de áudio '%s'" % bus_name)
		AudioServer.add_bus()
		var new_bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(new_bus_index, bus_name)
		# Por padrão, envia para o bus Master
		AudioServer.set_bus_send(new_bus_index, MASTER_BUS)

# Aplica as configurações de volume
func _apply_volume_settings() -> void:
	_set_bus_volume(MASTER_BUS, master_volume)
	_set_bus_volume(MUSIC_BUS, music_volume)
	_set_bus_volume(SFX_BUS, sfx_volume)
	_set_bus_volume(VOICE_BUS, voice_volume)
	_set_bus_volume(UI_BUS, ui_volume)
	_set_bus_volume(AMBIENT_BUS, ambient_volume)

# Define o volume para um bus específico
func _set_bus_volume(bus_name: String, volume: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		var db = linear_to_db(clamp(volume, 0.0, 1.0))
		AudioServer.set_bus_volume_db(bus_index, db)
	else:
		push_error("AudioManager: Bus '%s' não encontrado!" % bus_name)

# Configura os players de áudio
func _setup_audio_players() -> void:
	# Cria alguns players padrão para música e ambiente
	_create_audio_player("music_main", MUSIC_BUS)
	_create_audio_player("music_aux", MUSIC_BUS)
	_create_audio_player("ambient_main", AMBIENT_BUS)
	
	# Adiciona aos dicionários respectivos
	music_players["main"] = get_node("music_main")
	music_players["aux"] = get_node("music_aux")
	ambient_players["main"] = get_node("ambient_main")

# Cria um player de áudio
func _create_audio_player(name: String, bus: String) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.name = name
	player.bus = bus
	add_child(player)
	return player

# ===== API PÚBLICA =====

# MÚSICA

# Toca uma música com fade opcional
func play_music(track_name: String, track_path: String = "", fade_duration: float = 0.0, _loop: bool = true, volume: float = 1.0) -> void:
	if not initialized:
		push_error("AudioManager: Sistema de áudio não inicializado!")
		return
	
	# Se foi fornecido um caminho, usa esse; caso contrário, usa o nome como caminho
	var path = track_path if not track_path.is_empty() else track_name
	
	if current_music == path:
		print("AudioManager: Música '%s' já está tocando." % path)
		return
	
	# Carregar o recurso se necessário
	var stream = _get_or_load_audio(path)
	if not stream:
		push_error("AudioManager: Falha ao carregar música: %s" % path)
		return
	var player = music_players["main"]
	
	# Se quiser crossfade, use player auxiliar
	if fade_duration > 0.0 and player.playing:
		var aux_player = music_players["aux"]
		
		# Troca os players
		var temp = player
		player = aux_player
		aux_player = temp
		
		# Configura o novo player
		player.stream = stream
		player.volume_db = linear_to_db(0.0)  # Começa silencioso
		player.play()
		
		# Fade in do novo, fade out do antigo
		var tween = create_tween()
		tween.parallel().tween_property(player, "volume_db", linear_to_db(volume), fade_duration)
		tween.parallel().tween_property(aux_player, "volume_db", linear_to_db(0.0), fade_duration)
		tween.tween_callback(aux_player.stop)
	else:
		# Configuração direta sem crossfade
		if player.playing:
			player.stop()
		
		player.stream = stream
		player.volume_db = linear_to_db(volume)
		player.play()
	
	current_music = path
	music_started.emit(track_name)

# Para a música atual
func stop_music(fade_duration: float = 0.0) -> void:
	if not initialized or current_music.is_empty():
		return
	
	var player = music_players["main"]
	
	if fade_duration > 0.0:
		var tween = create_tween()
		tween.tween_property(player, "volume_db", linear_to_db(0.0), fade_duration)
		tween.tween_callback(player.stop)
	else:
		player.stop()
	
	music_stopped.emit(current_music)
	current_music = ""

# SFX

# Toca um efeito sonoro
func play_sfx(sound_path: String, volume: float = 1.0, pitch: float = 1.0) -> AudioStreamPlayer:
	if not initialized:
		push_error("AudioManager: Sistema de áudio não inicializado!")
		return null
	
	# Carregar o recurso
	var stream = _get_or_load_audio(sound_path)
	if not stream:
		push_error("AudioManager: Falha ao carregar SFX: %s" % sound_path)
		return null
	
	# Criar um player temporário para o SFX
	var player = AudioStreamPlayer.new()
	player.bus = SFX_BUS
	player.stream = stream
	player.volume_db = linear_to_db(volume)
	player.pitch_scale = pitch
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()
	
	sound_played.emit(sound_path)
	return player

# UI SOUNDS

# Toca um som da UI
func play_ui_sound(sound_name: String, sound_path: String = "", volume: float = 1.0) -> void:
	if not initialized:
		push_error("AudioManager: Sistema de áudio não inicializado!")
		return
	
	# Se foi fornecido um caminho, usa esse; caso contrário, usa o nome como caminho
	var path = sound_path if not sound_path.is_empty() else sound_name
	
	# Carregar o recurso
	var stream = _get_or_load_audio(path)
	if not stream:
		push_error("AudioManager: Falha ao carregar som UI: %s" % path)
		return
	
	# Criar um player temporário para o som UI
	var player = AudioStreamPlayer.new()
	player.bus = UI_BUS
	player.stream = stream
	player.volume_db = linear_to_db(volume)
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()
	
	sound_played.emit(sound_name)

# VOICE

# Toca um diálogo/voz
func play_voice(voice_path: String, volume: float = 1.0) -> AudioStreamPlayer:
	if not initialized:
		push_error("AudioManager: Sistema de áudio não inicializado!")
		return null
	
	# Carregar o recurso
	var stream = _get_or_load_audio(voice_path)
	if not stream:
		push_error("AudioManager: Falha ao carregar voz: %s" % voice_path)
		return null
	
	# Criar um player para a voz
	var player = AudioStreamPlayer.new()
	player.bus = VOICE_BUS
	player.stream = stream
	player.volume_db = linear_to_db(volume)
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()
	
	sound_played.emit(voice_path)
	return player

# AMBIENT

# Toca um som ambiente
func play_ambient(sound_path: String, fade_duration: float = 1.0, _loop: bool = true, volume: float = 1.0) -> void:
	if not initialized:
		push_error("AudioManager: Sistema de áudio não inicializado!")
		return
	
	if current_ambient == sound_path:
		return
	
	# Carregar o recurso
	var stream = _get_or_load_audio(sound_path)
	if not stream:
		push_error("AudioManager: Falha ao carregar ambiente: %s" % sound_path)
		return
	
	var player = ambient_players["main"]
	
	# Configura o player
	if player.playing:
		stop_ambient(fade_duration)
	
	player.stream = stream
	player.volume_db = linear_to_db(0.0)  # Começa silencioso
	player.play()
	
	# Fade in
	if fade_duration > 0.0:
		var tween = create_tween()
		tween.tween_property(player, "volume_db", linear_to_db(volume), fade_duration)
	else:
		player.volume_db = linear_to_db(volume)
	
	current_ambient = sound_path

# Para o som ambiente atual
func stop_ambient(fade_duration: float = 1.0) -> void:
	if not initialized or current_ambient.is_empty():
		return
	
	var player = ambient_players["main"]
	
	if fade_duration > 0.0:
		var tween = create_tween()
		tween.tween_property(player, "volume_db", linear_to_db(0.0), fade_duration)
		tween.tween_callback(player.stop)
	else:
		player.stop()
	
	current_ambient = ""

# VOLUME CONTROL

# Define o volume master
func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)
	_set_bus_volume(MASTER_BUS, master_volume)

# Define o volume da música
func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	_set_bus_volume(MUSIC_BUS, music_volume)

# Define o volume de SFX
func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	_set_bus_volume(SFX_BUS, sfx_volume)

# Define o volume de vozes
func set_voice_volume(volume: float) -> void:
	voice_volume = clamp(volume, 0.0, 1.0)
	_set_bus_volume(VOICE_BUS, voice_volume)

# Define o volume da UI
func set_ui_volume(volume: float) -> void:
	ui_volume = clamp(volume, 0.0, 1.0)
	_set_bus_volume(UI_BUS, ui_volume)

# Define o volume ambiente
func set_ambient_volume(volume: float) -> void:
	ambient_volume = clamp(volume, 0.0, 1.0)
	_set_bus_volume(AMBIENT_BUS, ambient_volume)

# HELPER FUNCTIONS

# Obtém ou carrega um recurso de áudio
func _get_or_load_audio(path: String) -> AudioStream:
	if sound_cache.has(path):
		return sound_cache[path]
		
	if not ResourceLoader.exists(path):
		push_error("AudioManager: Arquivo de áudio não encontrado: %s" % path)
		return null
	
	var stream = load(path)
	if not stream is AudioStream:
		push_error("AudioManager: Recurso não é um AudioStream: %s" % path)
		return null
	
	sound_cache[path] = stream
	return stream

# Limpa o cache de áudio
func clear_cache() -> void:
	sound_cache.clear()
	print("AudioManager: Cache de áudio limpo.")
