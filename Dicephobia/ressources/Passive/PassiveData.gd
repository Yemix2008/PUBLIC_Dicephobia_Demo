extends Resource

class_name PassiveData

@export var id: String = "" # Identifiant du Dé
@export var name: String = "" # Nom du Dé
@export var price: String = "" # Prix du Dé
@export var is_shop_item: bool = false # est ce qu il est dans le shop ou pas

func _init() -> void: # Atribution d'un Identifiant au Dé
	if id == "":
		id = str(Time.get_unix_time_from_system()) + "_" + str(randi())
