extends Resource

class_name DieData

@export var id: String = "" # Identifiant du Dé
@export var name: String = "" # Nom du Dé
@export var morph : String = "" # Altération du Dé
@export var sides : Array = [] # Faces du Dé
@export var augment : Array = [] # Amélioration de Faces du Dé
@export var price: int = 0 # Prix du Dé

func _init() -> void: # Atribution d'un Identifiant au Dé
	if id == "":
		id = str(Time.get_unix_time_from_system()) + "_" + str(randi())
