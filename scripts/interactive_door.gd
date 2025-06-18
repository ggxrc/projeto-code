extends InteractiveObject
class_name InteractiveDoor

# Script para portas interagíveis
# Para usar: Adicione esse script como nó filho de uma porta na cena

# Propriedades específicas para portas
@export_file("*.tscn") var target_scene: String = ""  # Cena para a qual a porta leva
@export var transition_effect: String = "loading"     # Efeito de transição ("loading", "fade", "instant")
@export var is_locked: bool = false                  # Se a porta está trancada
@export var need_key: String = ""                    # Nome da chave necessária (se trancada)
@export var locked_message: String = "Esta porta está trancada."

# Referências
var game_manager = null  # Referência para o gerenciador do jogo (orquestrador)
# Nota: área de interação agora é gerenciada pela classe pai (InteractiveObject)
var hint_label: Label = null

func _ready() -> void:
	# Configurar texto de interação padrão
	interaction_prompt = "Abrir Porta"
	
	# Tenta obter o gerenciador do jogo (orquestrador)
	game_manager = get_node_or_null("/root/Game")
	
	# Define o estado inicial de interação
	set_interaction_enabled(not is_locked)
	
	# Atualiza o texto de interação se a porta estiver trancada
	if is_locked:
		interaction_prompt = "Porta Trancada"
		
	# Chamada para o _ready() da classe pai para configurar a área de interação
	super._ready()

# Sobrescreve o método interact para manipular a transição de cena
func interact() -> void:
	if not interaction_enabled:
		print("Porta não pode ser interagida no momento")
		
		if is_locked:
			_show_lock_message()
		
		return
		
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_interaction_time < interaction_cooldown:
		return
		
	# Registra o tempo da interação
	last_interaction_time = current_time
	print("Interagindo com a porta: ", name)
	
	# Emite o sinal
	interaction_triggered.emit(self)
	
	# Inicia a transição de cena
	_transition_to_target_scene()

# Função para mostrar uma mensagem quando a porta está trancada
func _show_lock_message() -> void:
	print("Mostrando mensagem de porta trancada: ", locked_message)
	# Aqui você pode adicionar lógica para mostrar visualmente a mensagem ao jogador
	# Por exemplo, usando a caixa de descrição existente:
	
	if get_tree().current_scene.has_node("DescriptionBoxUI"):
		var desc_box = get_tree().current_scene.get_node("DescriptionBoxUI")
		if desc_box and desc_box.has_method("show_line"):
			desc_box.visible = true
			desc_box.show_line(locked_message)

# Tenta desbloquear a porta com uma chave
func try_unlock(key_name: String) -> bool:
	if not is_locked or key_name != need_key:
		return false
		
	is_locked = false
	interaction_prompt = "Abrir Porta"
	set_interaction_enabled(true)
	print("Porta desbloqueada com sucesso usando a chave: ", key_name)
	return true

# Função para lidar com a transição para a cena alvo
func _transition_to_target_scene() -> void:
	if target_scene.is_empty():
		print("ERRO: Nenhuma cena alvo definida para esta porta!")
		return
	
	# Tenta usar o gerenciador do jogo para transições suaves
	if game_manager:
		print("Usando gerenciador do jogo para transição para: ", target_scene)
		
		# Assumindo que o Game.gd tem um método para carregar cenas por caminho
		if game_manager.has_method("load_scene_by_path"):
			game_manager.load_scene_by_path(target_scene, transition_effect)
			return
			
		# Alternativa: navegar para GameState específico se corresponder a uma cena conhecida
		if target_scene.ends_with("Gameplay.tscn") and game_manager.has_method("navigate_to_gameplay"):
			game_manager.navigate_to_gameplay(transition_effect)
			return
			
		if target_scene.ends_with("MenuPrincipal.tscn") and game_manager.has_method("navigate_to_main_menu"):
			game_manager.navigate_to_main_menu(transition_effect)
			return
			
	# Fallback para mudança de cena direta se o gerenciador não estiver disponível
	print("Usando método direto para transição para: ", target_scene)
	
	# Se temos um sistema de transição global disponível
	if Engine.has_singleton("TransitionScreen"):
		var transition = Engine.get_singleton("TransitionScreen")
		if transition.has_method("fade_out"):
			transition.fade_out()
			await transition.fade_out_completed
		get_tree().change_scene_to_file(target_scene)
		if transition.has_method("fade_in"):
			transition.fade_in()
	else:
		# Fallback simples
		get_tree().change_scene_to_file(target_scene)
