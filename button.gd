extends Button

func _on_Iniciar_pressed():
	# Assumindo que Orquestrador está disponível em /root; se não, ajuste o caminho
	get_node("/root/Orquestrador").go_to_level_selector()
