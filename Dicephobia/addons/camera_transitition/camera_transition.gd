extends Node

# VARIABLES

var tween: Tween # Transiteur
var isTransitioning := false # Transitionne ? = Non

var camera2D := Camera2D.new() # Caméra de Transition 2D
var camera3D := Camera3D.new() # Caméra de Transition 3D

# PROGRAMME

func _ready(): # Au lancement, créé les Caméras de Transition et les Désactives
	add_child(camera2D)
	add_child(camera3D)
	camera2D.enabled = false
	camera3D.clear_current()

func transition_camera2D(from: Camera2D, to: Camera2D, duration: float = 1.0) -> void: # Transitionne d'une Caméra 2D (from) à une Autre (to) en une Durée (duration)
	if isTransitioning: return # Stop si déjà en cour de Transition

	# Initialise la Caméra de Transition et Switch de la Caméra de Départ à Celle-ci
	camera2D.zoom = from.zoom
	camera2D.offset = from.offset
	camera2D.global_transform = from.global_transform
	camera2D.make_current()

	isTransitioning = true # Transition ? = Oui
	
	if tween: # S'il existe déjà un Transiteur le Supprime
		tween.kill()
	tween = create_tween() # Créé un Transiteur

	# Fait la Transition (la Caméra de Transition suit le Transiteur)
	tween.tween_property(camera2D, "global_transform", to.global_transform, duration)
	tween.tween_property(camera2D, "zoom", to.zoom, duration)
	tween.tween_property(camera2D, "offset", to.offset, duration)

	await tween.finished # Attent la Fin de la Transition
	to.make_current() # Switch de la Caméra de Transition à la Caméra d'Arrivé
	isTransitioning = false # Transition ? = Non


func transition_camera3D(from: Camera3D, to: Camera3D, duration: float = 1.0) -> void: # Transitionne d'une Caméra 3D (from) à une Autre (to) en une Durée (duration)
	if isTransitioning: return # Stop si déjà en cour de Transition

	# Initialise la Caméra de Transition et Switch de la Caméra de Départ à Celle-ci
	camera3D.fov = from.fov
	camera3D.cull_mask = from.cull_mask
	camera3D.global_transform = from.global_transform
	camera3D.make_current()

	isTransitioning = true # Transition ? = Oui

	if tween: # S'il existe déjà un Transiteur le Supprime
		tween.kill()
	tween = create_tween() # Créé un Transiteur

	# Fait la Transition (la Caméra de Transition suit le Transiteur)
	tween.parallel().tween_property(camera3D, "global_transform", to.global_transform, duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(camera3D, "fov", to.fov, duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	await tween.finished # Attent la Fin de la Transition
	to.make_current() # Switch de la Caméra de Transition à la Caméra d'Arrivé
	isTransitioning = false # Transition ? = Non
