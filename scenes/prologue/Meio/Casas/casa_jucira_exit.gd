extends InteractiveObject

# Script para a porta de saída da casa da Jucira
# Agora herda de InteractiveObject para usar o sistema padrão de interação
# Este script deve ser adicionado como filho da cena CasaIdosaED.tscn

var target_scene_packed: PackedScene
var is_transitioning: bool = false

func _ready() -> void:
	# Configurar propriedades de InteractiveObject
	interaction_prompt = "Sair da casa"
	interaction_area_size = Vector2(20, 20)  # Mesmo tamanho do CollisionShape da porta
	interaction_cooldown = 1.0
	
	# Chamar _ready da classe pai (InteractiveObject) PRIMEIRO
	super._ready()
	
	# Carregar a cena de destino (Gameplay)
	target_scene_packed = load("res://scenes/prologue/Meio/Gameplay.tscn")
	if not target_scene_packed:
		return
	
	# Conectar ao sinal de interação
	if not interaction_triggered.is_connected(_on_interaction_triggered):
		interaction_triggered.connect(_on_interaction_triggered)

# Método chamado quando o InteractiveObject detecta interação
func _on_interaction_triggered(_interactive_object) -> void:
	if not is_transitioning:
		_exit_house()

# Método de compatibilidade para interação direta
func interact(_player = null) -> void:
	if not is_transitioning:
		_exit_house()

func _exit_house() -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	
	# Verificar se a cena foi carregada
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
