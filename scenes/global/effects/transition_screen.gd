# TransitionScreen.gd - Script Global/AutoLoad
extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

# Sinais para comunicar quando transições terminam
signal transition_finished
signal fade_in_finished
signal fade_out_finished

# Estado atual da transição
enum TransitionState {
	IDLE,
	FADING_OUT,
	FADING_IN
}

var current_state: TransitionState = TransitionState.IDLE
var is_transitioning: bool = false

# Referência para AudioManager
var audio_manager = null

func _ready() -> void:
	# Conecta sinais do AnimationPlayer
	if animation_player.animation_finished.connect(_on_animation_finished) != OK:
		print("Erro ao conectar sinal do AnimationPlayer")
	
	# Garante que inicia oculto
	color_rect.visible = false
	
	# Define layer alto para ficar acima de tudo
	layer = 100
	
	# Inicializa acesso ao AudioManager
	if Engine.has_singleton("AudioManager"):
		audio_manager = Engine.get_singleton("AudioManager")
		print("TransitionScreen: AudioManager encontrado como singleton.")

# Método principal para transição completa (fade out -> ação -> fade in)
func transition_to_scene(scene_path: String) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	
	# Fade out
	await fade_out()
	
	# Muda cena
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	
	# Fade in
	await fade_in()
	
	is_transitioning = false
	transition_finished.emit()

# Método para transição com callback customizado
func transition_with_callback(callback: Callable) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	
	# Fade out
	await fade_out()
	
	# Executa callback
	if callback.is_valid():
		await callback.call()
	
	# Fade in
	await fade_in()
	
	is_transitioning = false
	transition_finished.emit()

# Fade para preto (fade out)
func fade_out(duration: float = -1) -> void:
	if current_state == TransitionState.FADING_OUT:
		return
	
	current_state = TransitionState.FADING_OUT
	color_rect.visible = true
	
	# Reproduz som de transição (fade out)
	if audio_manager:
		audio_manager.play_sfx("interact", 0.5)
	
	if duration > 0:
		# Usa tween customizado
		var tween = create_tween()
		tween.tween_property(color_rect, "color:a", 1.0, duration)
		await tween.finished
	else:
		# Usa animação pré-definida
		animation_player.play("fade_to_black")
		await animation_player.animation_finished
	
	fade_out_finished.emit()

# Fade para transparente (fade in)
func fade_in(duration: float = -1) -> void:
	if current_state == TransitionState.FADING_IN:
		return
	
	current_state = TransitionState.FADING_IN
	
	if duration > 0:
		# Usa tween customizado
		var tween = create_tween()
		tween.tween_property(color_rect, "color:a", 0.0, duration)
		await tween.finished
	else:
		# Usa animação pré-definida
		animation_player.play("fade_to_normal")
		await animation_player.animation_finished
	
	# Reproduz som de fade in, se AudioManager estiver disponível
	if audio_manager != null:
		audio_manager.play_sound("fade_in_sound")
	
	color_rect.visible = false
	fade_in_finished.emit()

# Método legacy para compatibilidade
func transition() -> void:
	await fade_out()

# Métodos para diferentes tipos de transição
func quick_fade_out() -> void:
	await fade_out(0.2)

func slow_fade_out() -> void:
	await fade_out(1.0)

func quick_fade_in() -> void:
	await fade_in(0.2)

func slow_fade_in() -> void:
	await fade_in(1.0)

# Transição instantânea para preto
func instant_black() -> void:
	color_rect.visible = true
	color_rect.color.a = 1.0
	current_state = TransitionState.IDLE

# Transição instantânea para transparente
func instant_clear() -> void:
	color_rect.visible = false
	color_rect.color.a = 0.0
	current_state = TransitionState.IDLE

# Método para pausar durante transição
func transition_with_pause(pause_duration: float = 1.0) -> void:
	await fade_out()
	await get_tree().create_timer(pause_duration).timeout
	await fade_in()

# Callback do AnimationPlayer
func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"fade_to_black":
			current_state = TransitionState.IDLE
		"fade_to_normal":
			current_state = TransitionState.IDLE
			color_rect.visible = false

# Métodos utilitários
func _is_visible() -> bool:
	return color_rect.visible and color_rect.color.a > 0

func get_transition_state() -> TransitionState:
	return current_state

# Método para debug
func debug_state() -> void:
	print("TransitionScreen State: ", TransitionState.keys()[current_state])
	print("Is Transitioning: ", is_transitioning)
	print("Color Rect Visible: ", color_rect.visible)
	print("Alpha: ", color_rect.color.a)
