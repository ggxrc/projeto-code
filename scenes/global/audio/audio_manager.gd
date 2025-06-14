extends Node

signal music_finished
signal sfx_finished(sfx_name: String)

# Configurações
const MAX_SFX_PLAYERS = 8  # Número máximo de players de SFX simultâneos
const FADE_DURATION_DEFAULT = 1.0  # Duração padrão para fades (segundos)

# Grupos de volume (range 0.0 a 1.0)
var master_volume: float = 1.0
var music_volume: float = 1.0  # Volume máximo para música
var sfx_volume: float = 1.0    # Volume máximo para SFX

# Players de áudio
var music_player: AudioStreamPlayer
var current_music_path: String = ""
var music_tween: Tween

# Pool de players para efeitos sonoros
var sfx_pool: Array[AudioStreamPlayer] = []
var active_sfx: Dictionary = {}  # Mapeia nomes de SFX aos seus players ativos

# Caminhos dos recursos de áudio
var music_paths: Dictionary = {
	"menu": "res://assets/audio/songs/menu_theme.wav",
	"prologue": "res://assets/audio/songs/prologue_theme.wav",
	"gameplay": "res://assets/audio/songs/main_gameplay_theme.wav",
	"music_box": "res://assets/audio/songs/music_box.wav"
}

var sfx_paths: Dictionary = {
	"button_click": "res://assets/audio/sfx/button_click.wav",
	"dialogue_typing": "res://assets/audio/sfx/dialogue_typing.wav",
	"interact": "res://assets/audio/sfx/interact.wav",
	"footstep": "res://assets/audio/sfx/footstep.wav"
}

# Inicialização
func _ready() -> void:
	print("\n====== INICIALIZANDO AUDIOMANAGER ======")
	
	# Configuração do player de música
	music_player = AudioStreamPlayer.new()
	
	# Configurar barramento e propriedades
	music_player.bus = "Music"
	music_player.volume_db = 0.0  # Iniciar com volume máximo
	music_player.autoplay = false  # Não tocar automaticamente
	
	# Conectar sinal de finalização
	music_player.finished.connect(_on_music_finished)
	
	# Adicionar à árvore
	add_child(music_player)
	
	print("AudioManager: Player de música criado")
	
	# Definir volumes no máximo por padrão
	master_volume = 1.0
	music_volume = 1.0
	sfx_volume = 1.0
	
	# Criação da pool de SFX
	_initialize_sfx_pool()
	
	# Conectar ao barramento de áudio (AudioBus) se necessário
	_setup_audio_buses()
	
	# Carregar configurações salvas (se existirem)
	# Agora só carrega se o arquivo existir, caso contrário mantém os volumes máximos
	_load_saved_settings()
	
	# Garantir volumes adequados
	_ensure_audio_buses_volumes()
	
	# Verificar recursos de áudio
	_verify_audio_resources()
	
	print("AudioManager: Inicializado com sucesso!")
	
	# Aguardar um momento e verificar o status
	await get_tree().create_timer(0.5).timeout
	print("\nVerificação final: AudioManager pronto para uso!")
	print("- Music player configurado: ", music_player != null)
	print("- Music player na árvore: ", music_player.is_inside_tree())
	print("- Volume atual música: ", music_volume)
	print("- Volume atual SFX: ", sfx_volume)
	
# Verifica se os recursos de áudio estão disponíveis
func _verify_audio_resources() -> void:
	print("\n== Verificando recursos de áudio ==")
	
	# Verificar músicas
	print("Músicas registradas:")
	for music_name in music_paths:
		var path = music_paths[music_name]
		var exists = ResourceLoader.exists(path)
		print(" - ", music_name, ": ", path, " (Existe: ", exists, ")")
		
	# Verificar SFX
	print("Efeitos sonoros registrados:")
	for sfx_name in sfx_paths:
		var path = sfx_paths[sfx_name]
		var exists = ResourceLoader.exists(path)
		print(" - ", sfx_name, ": ", path, " (Existe: ", exists, ")")
	
	print("=================================")

# Inicializa a pool de players de efeitos sonoros
func _initialize_sfx_pool() -> void:
	for i in range(MAX_SFX_PLAYERS):
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.bus = "SFX"
		sfx_player.finished.connect(_on_sfx_finished.bind(sfx_player))
		add_child(sfx_player)
		sfx_pool.append(sfx_player)
	
	print("AudioManager: Pool de SFX criada com %d players" % MAX_SFX_PLAYERS)

# Configura barramentos de áudio se necessário
func _setup_audio_buses() -> void:
	print("\n== Configurando barramentos de áudio ==")
	# Verificar se os barramentos existem, senão criar
	var audio_server = AudioServer
	
	# Verificar Master bus
	var master_bus_idx = audio_server.get_bus_index("Master")
	if master_bus_idx >= 0:
		print("Bus Master encontrado no índice ", master_bus_idx)
		print("Master muted: ", audio_server.is_bus_mute(master_bus_idx))
		print("Master volume: ", audio_server.get_bus_volume_db(master_bus_idx), "dB")
	else:
		print("ERRO: Bus Master não encontrado!")
	
	# Configurar Music bus
	var music_bus_idx = audio_server.get_bus_index("Music")
	if music_bus_idx < 0:
		print("Criando barramento Music...")
		audio_server.add_bus()
		music_bus_idx = audio_server.get_bus_count() - 1
		audio_server.set_bus_name(music_bus_idx, "Music")
		audio_server.set_bus_send(music_bus_idx, "Master")
		print("AudioManager: Barramento Music criado no índice ", music_bus_idx)
	else:
		print("Bus Music já existe no índice ", music_bus_idx)
	
	# Configurar SFX bus
	var sfx_bus_idx = audio_server.get_bus_index("SFX")
	if sfx_bus_idx < 0:
		print("Criando barramento SFX...")
		audio_server.add_bus()
		sfx_bus_idx = audio_server.get_bus_count() - 1
		audio_server.set_bus_name(sfx_bus_idx, "SFX")
		audio_server.set_bus_send(sfx_bus_idx, "Master")
		print("AudioManager: Barramento SFX criado no índice ", sfx_bus_idx)
	else:
		print("Bus SFX já existe no índice ", sfx_bus_idx)
	
	# Garantir que os barramentos não estão mudos
	if master_bus_idx >= 0 and audio_server.is_bus_mute(master_bus_idx):
		print("Desmutando barramento Master")
		audio_server.set_bus_mute(master_bus_idx, false)
	
	if music_bus_idx >= 0 and audio_server.is_bus_mute(music_bus_idx):
		print("Desmutando barramento Music")
		audio_server.set_bus_mute(music_bus_idx, false)
	
	if sfx_bus_idx >= 0 and audio_server.is_bus_mute(sfx_bus_idx):
		print("Desmutando barramento SFX")
		audio_server.set_bus_mute(sfx_bus_idx, false)
	
	_ensure_audio_buses_volumes()

# Certifica-se de que os barramentos de áudio estão configurados com volume adequado
func _ensure_audio_buses_volumes() -> void:
	print("\n== Garantindo volumes dos barramentos de áudio ==")
	var audio_server = AudioServer
	
	# Verifique se os volumes são razoáveis, caso contrário redefina para o máximo
	if master_volume <= 0.01 or music_volume <= 0.01 or sfx_volume <= 0.01:
		print("ATENÇÃO: Volumes muito baixos detectados! Redefinindo para valores padrão...")
		_reset_volumes_to_defaults()
	
	# Master bus
	var master_bus_idx = audio_server.get_bus_index("Master")
	if master_bus_idx >= 0:
		if audio_server.is_bus_mute(master_bus_idx):
			print("Desmutando barramento Master")
			audio_server.set_bus_mute(master_bus_idx, false)
		
		# Aplicar o volume atual do master
		var master_db = linear_to_db(master_volume)
		audio_server.set_bus_volume_db(master_bus_idx, master_db)
		print("Master bus configurado: Mute=", audio_server.is_bus_mute(master_bus_idx),
				", Volume=", audio_server.get_bus_volume_db(master_bus_idx), "dB")
	
	# Music bus
	var music_bus_idx = audio_server.get_bus_index("Music")
	if music_bus_idx >= 0:
		if audio_server.is_bus_mute(music_bus_idx):
			print("Desmutando barramento Music")
			audio_server.set_bus_mute(music_bus_idx, false)
		
		# Aplicar o volume atual da música
		var music_db = linear_to_db(music_volume)
		audio_server.set_bus_volume_db(music_bus_idx, music_db)
		print("Music bus configurado: Mute=", audio_server.is_bus_mute(music_bus_idx),
				", Volume=", audio_server.get_bus_volume_db(music_bus_idx), "dB")
	
	# SFX bus
	var sfx_bus_idx = audio_server.get_bus_index("SFX")
	if sfx_bus_idx >= 0:
		if audio_server.is_bus_mute(sfx_bus_idx):
			print("Desmutando barramento SFX")
			audio_server.set_bus_mute(sfx_bus_idx, false)
		
		# Aplicar o volume atual de SFX
		var sfx_db = linear_to_db(sfx_volume)
		audio_server.set_bus_volume_db(sfx_bus_idx, sfx_db)
		print("SFX bus configurado: Mute=", audio_server.is_bus_mute(sfx_bus_idx),
				", Volume=", audio_server.get_bus_volume_db(sfx_bus_idx), "dB")
	
	# Verificar se algum barramento ainda está com volume baixo demais
	if (master_bus_idx >= 0 and audio_server.get_bus_volume_db(master_bus_idx) < -40.0) or \
	   (music_bus_idx >= 0 and audio_server.get_bus_volume_db(music_bus_idx) < -40.0) or \
	   (sfx_bus_idx >= 0 and audio_server.get_bus_volume_db(sfx_bus_idx) < -40.0):
		push_warning("ATENÇÃO: Algum barramento de áudio ainda está com volume muito baixo!")
		
		var master_vol_text = "N/A"
		var music_vol_text = "N/A"
		var sfx_vol_text = "N/A"
		
		if master_bus_idx >= 0:
			master_vol_text = str(audio_server.get_bus_volume_db(master_bus_idx)) + "dB"
		if music_bus_idx >= 0:
			music_vol_text = str(audio_server.get_bus_volume_db(music_bus_idx)) + "dB"
		if sfx_bus_idx >= 0:
			sfx_vol_text = str(audio_server.get_bus_volume_db(sfx_bus_idx)) + "dB"
		
		print("- Master: ", master_vol_text)
		print("- Music: ", music_vol_text)
		print("- SFX: ", sfx_vol_text)

# === CONTROLE DE MÚSICA ===

# Toca uma música com possibilidade de fade in
func play_music(music_name: String, fade_in: float = 0.0, volume: float = -1.0) -> void:
	print("\n== PLAY_MUSIC CHAMADO ==")
	print("Música solicitada: " + music_name)
	print("Fade in: " + str(fade_in))
	print("Volume solicitado: " + str(volume))
	
	# Verificar se a música existe no dicionário
	if music_name == "" or not music_paths.has(music_name):
		push_error("AudioManager: Música não encontrada: " + music_name)
		return
	
	var path = music_paths[music_name]
	print("Caminho do arquivo: " + path)
	
	# Verificar se o arquivo existe
	if not ResourceLoader.exists(path):
		push_error("AudioManager: Arquivo de música não encontrado: " + path)
		return
	
	# Carregar o recurso de áudio
	var music_resource = load(path)
	if music_resource == null:
		push_error("AudioManager: Falha ao carregar música: " + path)
		return
	
	print("Recurso carregado com sucesso: " + str(music_resource))
	print("Tipo do recurso: " + str(music_resource.get_class()))
	
	# Verificar estado atual do player de música
	print("Estado atual do music_player:")
	print("- Está na árvore: " + str(music_player.is_inside_tree()))
	print("- Volume atual: " + str(music_player.volume_db) + "dB")
	print("- Tocando atualmente: " + str(music_player.playing))
	
	# Interromper qualquer música atual
	if music_player.playing:
		print("Interrompendo música atual")
		music_player.stop()
	
	# Interromper qualquer tween em andamento
	if music_tween and music_tween.is_valid():
		print("Interrompendo tween anterior")
		music_tween.kill()
	
	# Atualizar estado e configurar nova música
	current_music_path = path
	music_player.stream = music_resource
	
	# Configurar volume alvo
	var target_volume = volume if volume >= 0 else music_volume
	print("Volume alvo (linear): " + str(target_volume))
	var target_db = linear_to_db(target_volume * master_volume)
	print("Volume alvo (dB): " + str(target_db))
	
	# Aplicar fade in ou tocar diretamente
	if fade_in > 0:
		print("Aplicando fade in de " + str(fade_in) + " segundos")
		music_player.volume_db = -80  # Começar com volume muito baixo
		music_player.play()
		
		music_tween = create_tween()
		music_tween.tween_property(music_player, "volume_db", target_db, fade_in)
		music_tween.play()
	else:
		# Sem fade, volume direto e tocar
		print("Tocando imediatamente sem fade")
		music_player.volume_db = target_db
		music_player.play()
	
	print("AudioManager: Tocando música: " + music_name)
	print("=======================")

# Interrompe a música atual com possibilidade de fade out
func stop_music(fade_out: float = 0.0) -> void:
	if not music_player.playing:
		return
		
	if fade_out > 0:
		# Para qualquer fade atual
		if music_tween and music_tween.is_valid():
			music_tween.kill()
		
		# Cria um novo fade
		music_tween = create_tween()
		music_tween.tween_property(music_player, "volume_db", -80, fade_out)
		music_tween.tween_callback(music_player.stop)
		music_tween.play()
	else:
		music_player.stop()
	
	print("AudioManager: Música interrompida")

# Pausa a música atual
func pause_music() -> void:
	if music_player.playing:
		music_player.stream_paused = true
		print("AudioManager: Música pausada")

# Retoma a música pausada
func resume_music() -> void:
	if music_player.stream_paused:
		music_player.stream_paused = false
		print("AudioManager: Música retomada")

# === CONTROLE DE EFEITOS SONOROS ===

# Toca um efeito sonoro
func play_sfx(sfx_name: String, volume: float = -1.0, pitch_scale: float = 1.0) -> AudioStreamPlayer:
	# Versão otimizada - menos logs para desempenho melhor
	
	if sfx_name == "" or not sfx_paths.has(sfx_name):
		push_error("AudioManager: SFX não encontrado: " + sfx_name)
		return null
	
	var path = sfx_paths[sfx_name]
	
	# Carrega o recurso de som
	var sfx_resource
	if ResourceLoader.exists(path):
		sfx_resource = load(path)
		if sfx_resource == null:
			push_error("AudioManager: Falha ao carregar o recurso: " + path)
			return null
	else:
		push_error("AudioManager: Arquivo de SFX não encontrado: " + path)
		return null
	
	# Obtém um player disponível da pool
	var sfx_player = _get_available_sfx_player()
	if not sfx_player:
		push_warning("AudioManager: Todos os players de SFX estão ocupados. Aumentar MAX_SFX_PLAYERS?")
		return null
	
	# Configura o player
	sfx_player.stream = sfx_resource
	sfx_player.pitch_scale = pitch_scale
	
	# Configura o volume
	var target_volume = volume if volume >= 0 else sfx_volume
	sfx_player.volume_db = linear_to_db(target_volume * master_volume)
	
	# Armazena referência ao SFX ativo
	active_sfx[sfx_player.get_instance_id()] = sfx_name
	
	# Toca o som com prioridade
	sfx_player.play()
	
	return sfx_player

# Toca um SFX na posição 2D (espacializado) - para implementação futura
func play_sfx_at_position(sfx_name: String, _position: Vector2, volume: float = -1.0, pitch_scale: float = 1.0) -> void:
	# Versão futura: implementar AudioStreamPlayer2D para sons posicionais
	# Por enquanto usa a função padrão
	play_sfx(sfx_name, volume, pitch_scale)

# Adiciona novos caminhos de áudio
func add_music(music_name: String, path: String) -> void:
	if music_name != "" and path != "":
		music_paths[music_name] = path
		print("AudioManager: Música adicionada: " + music_name + " -> " + path)

func add_sfx(sfx_name: String, path: String) -> void:
	if sfx_name != "" and path != "":
		sfx_paths[sfx_name] = path
		print("AudioManager: SFX adicionado: " + sfx_name + " -> " + path)

# === GERENCIAMENTO DE VOLUME ===

# Define o volume principal
func set_master_volume(value: float) -> void:
	master_volume = clamp(value, 0.0, 1.0)	# Atualiza os volumes atuais
	var music_db = linear_to_db(master_volume * music_volume)
	var _sfx_db = linear_to_db(master_volume * sfx_volume)
	
	# Atualiza o volume no AudioServer
	var master_bus_idx = AudioServer.get_bus_index("Master")
	if master_bus_idx >= 0:
		AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(master_volume))
	
	# Atualiza o player de música se estiver tocando
	if music_player.playing:
		music_player.volume_db = music_db
	
	print("AudioManager: Volume principal definido para " + str(master_volume))

# Define o volume da música
func set_music_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, 1.0)
	
	# Atualiza o barramento de música
	var music_bus_idx = AudioServer.get_bus_index("Music")
	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(music_volume))
	
	# Atualiza o player atual se estiver tocando
	if music_player.playing:
		music_player.volume_db = linear_to_db(music_volume * master_volume)
	
	print("AudioManager: Volume de música definido para " + str(music_volume))

# Define o volume dos efeitos sonoros
func set_sfx_volume(value: float) -> void:
	sfx_volume = clamp(value, 0.0, 1.0)
	
	# Atualiza o barramento de SFX
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(sfx_volume))
	
	print("AudioManager: Volume de SFX definido para " + str(sfx_volume))

# === FUNÇÕES UTILITÁRIAS ===

# Obtém um player de SFX disponível da pool
func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_pool:
		if not player.playing:
			return player
	
	# Se todos estiverem ocupados, retorna null
	return null

# Callbacks
func _on_music_finished() -> void:
	print("AudioManager: Música finalizada")
	music_finished.emit()

func _on_sfx_finished(sfx_player: AudioStreamPlayer) -> void:
	var id = sfx_player.get_instance_id()
	
	if active_sfx.has(id):
		var sfx_name = active_sfx[id]
		sfx_finished.emit(sfx_name)
		active_sfx.erase(id)

# Carrega as configurações de volume salvadas anteriormente
func _load_saved_settings() -> void:
	var config = ConfigFile.new()
	
	print("\n== Carregando configurações de áudio ==")
	
	# Tenta carregar as configurações
	var err = config.load("user://audio_settings.cfg")
	
	# Se o arquivo existe e foi carregado com sucesso
	if err == OK:
		# Obter volumes salvos (com valores padrão caso não existam)
		var saved_master_volume = config.get_value("audio", "master_volume", 1.0)
		var saved_music_volume = config.get_value("audio", "music_volume", 1.0)
		var saved_sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
		
		# Verificar se os valores são razoáveis (acima de um mínimo)
		# Isso evita situações onde o jogo inicia mudo por conta de configurações muito baixas
		var min_volume = 0.05  # 5% do volume como mínimo aceitável para primeira execução
		
		if saved_master_volume >= min_volume and saved_music_volume >= min_volume and saved_sfx_volume >= min_volume:
			# Aplicar os volumes apenas se forem aceitáveis
			set_master_volume(saved_master_volume)
			set_music_volume(saved_music_volume)
			set_sfx_volume(saved_sfx_volume)
			
			print("Configurações de áudio carregadas:")
			print("- Master: ", saved_master_volume)
			print("- Música: ", saved_music_volume)
			print("- SFX: ", saved_sfx_volume)
		else:
			print("Volumes salvos eram muito baixos. Usando valores máximos para evitar som mudo.")
			_reset_volumes_to_defaults()
	else:
		print("Arquivo de configurações não encontrado ou inválido. Usando valores padrão máximos.")
		_reset_volumes_to_defaults()
	
	print("====================================")
	
# Redefine os volumes para seus valores padrão (máximos)
func _reset_volumes_to_defaults() -> void:
	print("Redefinindo volumes para valores padrão (máximos)")
	set_master_volume(1.0)
	set_music_volume(1.0)
	set_sfx_volume(1.0)
	
	print("- Master: ", master_volume)
	print("- Música: ", music_volume)
	print("- SFX: ", sfx_volume)

# Salva as configurações de volume atuais
func save_settings() -> void:
	var config = ConfigFile.new()
	
	print("\n== Salvando configurações de áudio ==")
	
	# Verificar se algum volume está muito baixo 
	var min_safe_volume = 0.05  # 5% do volume para evitar que fique completamente mudo
	
	# Verificar se algum volume está muito baixo (especialmente o master)
	if master_volume < min_safe_volume:
		push_warning("AudioManager: Volume master muito baixo para salvar. Ajustando para o mínimo seguro.")
		master_volume = min_safe_volume
	
	# Define os valores a serem salvos
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	
	# Salva o arquivo
	var err = config.save("user://audio_settings.cfg")
	if err != OK:
		push_error("AudioManager: Erro ao salvar configurações: " + str(err))
	else:
		print("AudioManager: Configurações salvas com sucesso.")
		print("- Master: ", master_volume)
		print("- Música: ", music_volume)
		print("- SFX: ", sfx_volume)
	
	print("====================================")
