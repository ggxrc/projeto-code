extends InteractiveObject

class_name Jukebox

# Sinal emitido quando uma música começa a tocar
signal song_started(song_name: String)
# Sinal emitido quando uma música termina
signal song_ended(song_name: String)

# Playlist de músicas disponíveis
var playlist: Dictionary = {
	"Menu Theme": "menu",
	"Gameplay Theme": "gameplay", 
	"Prologue": "prologue",
	"Music Box": "music_box"
}

# Estado atual da jukebox
var is_playing: bool = false
var current_song_name: String = ""
var current_song_index: int = -1

# Referência ao AudioManager
var audio_manager

# Lista ordenada de nomes de músicas para facilitar a navegação
var song_names: Array = []

# Configuração
@export var auto_play: bool = false
@export var fade_duration: float = 1.0

func _ready():
	# Configurar o prompt de interação
	interaction_prompt = "Usar Jukebox"
	
	# Chamar o _ready() da classe pai (InteractiveObject)
	super._ready()
	
	# Obter referência do AudioManager
	audio_manager = AudioManager

	# Conectar ao sinal de música finalizada
	if audio_manager:
		audio_manager.music_finished.connect(_on_music_finished)
	
	# Preparar lista ordenada de nomes das músicas
	song_names = playlist.keys()
	
	# Se autoplay estiver habilitado, começar a primeira música
	if auto_play and not song_names.is_empty():
		play_song(song_names[0])

# Esta função é chamada quando o jogador interage com o jukebox
# Sobrescrevendo o método da classe pai (InteractiveObject)
func _on_interaction(object):
	# Verifica se a interação foi com este objeto
	if object == self:
		# Ativar/desativar o jukebox
		toggle_play()

# Alterna entre tocar e pausar
func toggle_play():
	if is_playing:
		stop_playback()
	else:
		# Se não estiver tocando, começar a tocar
		if current_song_index == -1:
			# Primeira vez, tocar a primeira música
			play_song(song_names[0])
		else:
			# Continuar de onde parou
			play_song(song_names[current_song_index])
			
	# Desabilita interação por um momento para evitar cliques duplos
	interaction_enabled = false
	await get_tree().create_timer(interaction_cooldown).timeout
	interaction_enabled = true

# Toca a próxima música na playlist
func next_song():
	if song_names.is_empty():
		return
	
	var next_index = (current_song_index + 1) % song_names.size()
	play_song(song_names[next_index])

# Toca a música anterior na playlist
func previous_song():
	if song_names.is_empty():
		return
	
	var prev_index = current_song_index - 1
	if prev_index < 0:
		prev_index = song_names.size() - 1
	
	play_song(song_names[prev_index])

# Toca uma música específica pelo nome
func play_song(song_name: String):
	if not playlist.has(song_name) or not audio_manager:
		return
	
	# Parar qualquer música atual
	if is_playing:
		audio_manager.stop_music(fade_duration / 2)
		await get_tree().create_timer(fade_duration / 2).timeout
	
	# Atualizar estado
	current_song_name = song_name
	current_song_index = song_names.find(song_name)
	is_playing = true
	
	# Obter o ID da música no AudioManager
	var music_id = playlist[song_name]
	
	# Tocar música com fade in
	audio_manager.play_music(music_id, fade_duration)
	
	# Emitir sinal
	song_started.emit(song_name)
	
	print("Jukebox: Tocando '" + song_name + "' (ID: " + music_id + ")")

# Para a reprodução atual
func stop_playback():
	if not is_playing or not audio_manager:
		return
	
	audio_manager.stop_music(fade_duration)
	is_playing = false
	
	print("Jukebox: Parando reprodução")

# Chamado quando uma música termina (via sinal do AudioManager)
func _on_music_finished():
	if is_playing:
		# Se a jukebox ainda está no modo "tocando", vá para a próxima música
		print("Jukebox: Música finalizada, avançando para a próxima")
		song_ended.emit(current_song_name)
		next_song()
	else:
		print("Jukebox: Música finalizada")