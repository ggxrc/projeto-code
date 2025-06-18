extends InteractiveObject
class_name InteractiveLever

signal lever_activated
signal lever_deactivated

# Estado da alavanca
var is_active: bool = false

# Configurações
@export var toggle_mode: bool = true  # Se false, a alavanca volta para a posição original depois de um tempo
@export var auto_return_delay: float = 2.0  # Tempo para voltar à posição original (se toggle_mode = false)
@export var activation_target_path: NodePath  # Caminho para o nó que será afetado pela alavanca
@export var active_prompt: String = "Desativar Alavanca"
@export var inactive_prompt: String = "Ativar Alavanca"

# Referências
@export var lever_sprite: Node2D = null  # Referência para o sprite da alavanca (para animação)

# Sons
@export var activation_sound: String = "lever_on"
@export var deactivation_sound: String = "lever_off"

func _ready():
	# Configura o prompt inicial
	interaction_prompt = inactive_prompt if not is_active else active_prompt
	
	# Chama o ready da classe pai
	super._ready()

# Método chamado pelo sistema universal de interação
func interact():
	if not interaction_enabled:
		return
		
	# Verificar cooldown
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_interaction_time < interaction_cooldown:
		return
		
	last_interaction_time = current_time
	
	# Alternar estado da alavanca
	if is_active:
		deactivate_lever()
	else:
		activate_lever()
	
	# Emite o sinal de interação
	interaction_triggered.emit(self)

# Ativa a alavanca
func activate_lever():
	is_active = true
	
	# Atualiza o prompt
	interaction_prompt = active_prompt
	if player_node and player_node.has_method("atualizar_botao_interacao"):
		player_node.atualizar_botao_interacao()
	
	# Anima a alavanca
	_animate_lever(true)
	
	# Toca som de ativação
	_play_sound(activation_sound)
	
	# Emite sinal
	lever_activated.emit()
	
	# Afeta o alvo configurado
	_affect_target(true)
	
	# Se não estiver no modo toggle, programa o retorno automático
	if not toggle_mode:
		var timer = get_tree().create_timer(auto_return_delay)
		timer.timeout.connect(deactivate_lever)

# Desativa a alavanca
func deactivate_lever():
	is_active = false
	
	# Atualiza o prompt
	interaction_prompt = inactive_prompt
	if player_node and player_node.has_method("atualizar_botao_interacao"):
		player_node.atualizar_botao_interacao()
	
	# Anima a alavanca
	_animate_lever(false)
	
	# Toca som de desativação
	_play_sound(deactivation_sound)
	
	# Emite sinal
	lever_deactivated.emit()
	
	# Afeta o alvo configurado
	_affect_target(false)

# Anima a alavanca ativando/desativando
func _animate_lever(active: bool):
	if lever_sprite:
		var angle = -45.0 if active else 45.0  # Ângulo de rotação da alavanca
		
		var tween = create_tween()
		tween.tween_property(lever_sprite, "rotation_degrees", angle, 0.2)

# Toca um som usando o AudioManager
func _play_sound(sound_name: String):
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		if audio_manager.has_method("play_sfx"):
			audio_manager.play_sfx(sound_name)

# Afeta o nó alvo quando a alavanca é ativada/desativada
func _affect_target(active: bool):
	if activation_target_path.is_empty():
		return
		
	var target = get_node_or_null(activation_target_path)
	if not target:
		return
		# Verifica o tipo de nó alvo e realiza ação apropriada
	if target.has_method("set_active"):
		# Nós genéricos com método set_active
		target.set_active(active)
	elif target is Light2D:
		# Luz
		target.enabled = active
	elif target.has_method("open_door") and target.has_method("close_door"):
		# Porta
		if active:
			target.open_door()
		else:
			target.close_door()
	elif target.has_method("interact"):
		# Outros objetos interativos
		target.interact()
