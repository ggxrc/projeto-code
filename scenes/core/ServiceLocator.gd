extends Node
# ServiceLocator.gd
# Centraliza acesso a todos os sistemas do jogo
# Singleton global registrado no projeto

# Dicionário de serviços registrados
var _services = {}

# Registra um serviço no localizador
func register_service(service_name: String, service_instance) -> void:
	if _services.has(service_name):
		push_warning("ServiceLocator: Serviço '%s' já registrado, substituindo." % service_name)
	
	_services[service_name] = service_instance
	print("ServiceLocator: Serviço '%s' registrado com sucesso." % service_name)

# Obtém uma referência a um serviço
func get_service(service_name: String):
	if not _services.has(service_name):
		push_error("ServiceLocator: Serviço '%s' não encontrado!" % service_name)
		return null
		
	return _services[service_name]

# Verifica se um serviço existe
func has_service(service_name: String) -> bool:
	return _services.has(service_name)

# Remove um serviço registrado
func unregister_service(service_name: String) -> void:
	if _services.has(service_name):
		_services.erase(service_name)
		print("ServiceLocator: Serviço '%s' removido." % service_name)
	else:
		push_warning("ServiceLocator: Tentativa de remover serviço '%s' inexistente." % service_name)

# Lista todos os serviços registrados (útil para debug)
func list_services() -> Array:
	return _services.keys()
