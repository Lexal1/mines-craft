extends CharacterBody3D

const SPEED = 6.0
const JUMP_VELOCITY = 5.0
const BREAKSFX = preload("res://assets/audio/break.wav")
const PLACESFX = preload("res://assets/audio/place.wav")

var selected = 6
var sensitivity = 0.005

var paused = false
var perspective = false
var dead = false

@onready var camera = $Camera
@onready var raycast = $Camera/RayCast
@onready var blok: AudioStreamPlayer3D = $Camera/RayCast/blok
#@onready var block_outline: MeshInstance3D = $BlockOutline

signal place_block(pos,t)
signal break_block(pos)
signal die()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent):
	if Input.is_action_just_pressed("pause"):
		paused = not paused
		if paused: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if paused: return
	
	if event is InputEventMouseMotion:
		rotation.y = rotation.y - event.relative.x * sensitivity
		camera.rotation.x = camera.rotation.x - event.relative.y * sensitivity
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	if Input.is_action_just_pressed("perspective"):
		perspective = not perspective
		if perspective:
			camera.position.y = 3
			camera.position.z = 5
		else:
			camera.position.y = 0.5
			camera.position.z = 0

func _physics_process(delta: float) -> void:
	if position.y <= -25 and !dead:
		dead = true
		die.emit()

	# add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# handle input direction and handle the movement/deceleration
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if raycast.is_colliding():
		var norm = raycast.get_collision_normal()
		var pos = raycast.get_collision_point() - norm * 0.5
		
		var bx = floor(pos.x) +0.5
		var by = floor(pos.y) +0.5
		var bz = floor(pos.z) +0.5
		var bpos = Vector3(bx,by,bz) - self.position
		
		#block_outline.position = bpos
		#block_outline.visible = true
		
		if Input.is_action_just_pressed("1"):
			blok.stream = BREAKSFX
			emit_signal("break_block", pos)
			blok.play()
		if Input.is_action_just_pressed("2"):
			blok.stream = PLACESFX
			emit_signal("place_block", pos +norm, Blocks.PLATE)
			blok.play()
	#else:
		#block_outline.visible = false

	move_and_slide()
