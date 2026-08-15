extends Node3D

var chunk_scene = preload("res://scenes/chunk.tscn")

@export var render_distance = 5 ## Determines how many chunks to load around the player, in a radius.

@onready var world: Node3D = $World
@onready var player: CharacterBody3D = $Player
@onready var environment: WorldEnvironment = $WorldEnvironment
@onready var die: AudioStreamPlayer = $die

func _ready() -> void:
	for i in range(0, render_distance):
		for j in range(0, render_distance):
			var chunk = chunk_scene.instantiate()
			chunk.chunk_position = Vector2(i,j)
			world.add_child(chunk)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug1"):
		chunk_processing()
	self.call_deferred("chunk_processing")

func chunk_processing():
	for c in world.get_children():
		var cx = c.chunk_position.x
		var cz = c.chunk_position.y
		
		var px = floor(player.position.x / Global.CHUNK_SIZE.x)
		var pz = floor(player.position.z / Global.CHUNK_SIZE.z)
		
		var newx = posmod(cx - px + render_distance/2, render_distance) + px - render_distance/2
		var newz = posmod(cz - pz + render_distance/2, render_distance) + pz - render_distance/2
		
		if (newx != cx or newz != cz):
			c.chunk_position = Vector2(int(newx),int(newz))
			c.generate()
			c.update()
		

func get_chunk(pos):
	for c in world.get_children():
		if c.chunk_position == pos:
			return c
	return null

func _on_player_place_block(pos: Variant, t: Variant) -> void:
	var cx = int(floor(pos.x / Global.CHUNK_SIZE.x))
	var cz = int(floor(pos.z / Global.CHUNK_SIZE.z))
	
	var bx = posmod(floor(pos.x), Global.CHUNK_SIZE.x)
	var by = posmod(floor(pos.y), Global.CHUNK_SIZE.y)
	var bz = posmod(floor(pos.z), Global.CHUNK_SIZE.z)
	
	var c = get_chunk(Vector2(cx,cz))
	if c != null:
		c.blocks[bx][by][bz] = t
		c.update()

func _on_player_break_block(pos: Variant) -> void:
	_on_player_place_block(pos, Blocks.AIR)


func _on_player_die() -> void:
	Global.music.stream_paused = true
	environment.environment.background_mode = Environment.BG_KEEP
	die.play()
	await die.finished
	get_tree().quit()
	
