extends InteractiveObject

# Script para a porta da casa da Jucira
# Implementa transição de cena usando change_scene_to_packed()
# Agora herda de InteractiveObject para usar o sistema padrão de interação

# Referências
var target_scene_packed: PackedScene
var is_transitioning: bool = false

func _ready() -> void:
	# Configurar propriedades de InteractiveObject
	interaction_prompt = "Entrar na casa"
	interaction_area_size = Vector2(20, 20)
	interaction_cooldown = 1.0
	
	# Chamar _ready da classe pai (InteractiveObject) PRIMEIRO
	super._ready()
	
	# Posicionar a área de interação na posição específica da porta
	if area_node:
		area_node.position = Vector2(22.143, 23.571)
	
	# Carregar a cena da casa da Jucira
	target_scene_packed = load("res://scenes/prologue/Meio/Casas/CasaIdosaED.tscn")
	if not target_scene_packed:
		return
	
	# Conectar ao sinal de interação
	if not interaction_triggered.is_connected(_on_interaction_triggered):
		interaction_triggered.connect(_on_interaction_triggered)

# Método chamado quando o InteractiveObject detecta interação
func _on_interaction_triggered(_interactive_object) -> void:
	if not is_transitioning:
		_transition_to_house()

# Método de compatibilidade para interação direta
func interact(_player = null) -> void:
	if not is_transitioning:
		_transition_to_house()

func _transition_to_house() -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	
	# Verificar se a cena foi carregada corretamente
	if not target_scene_packed:
		is_transitioning = false
		return
	
	# Tocar som de interação se disponível
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		audio_manager.play_sfx("interact")
	
	# Realizar a transição usando change_scene_to_packed
	var result = get_tree().change_scene_to_packed(target_scene_packed)
	
	if result != OK:
		is_transitioning = false
