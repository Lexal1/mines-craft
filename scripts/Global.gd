extends Node

const SYNTH_1 = preload("res://assets/audio/synth1.wav")
const SYNTH_2 = preload("res://assets/audio/synth2.wav")
const SYNTH_3 = preload("res://assets/audio/synth3.wav")

@onready var music_timer: Timer = $Music/Timer
@onready var music: AudioStreamPlayer = $Music

const CHUNK_SIZE = Vector3(16,32,16)

const TEXTURE_ATLAS_SIZE = Vector2(4,4)

func _process(delta: float) -> void:
	await music_timer.timeout
	play_track()
	await music.finished
	music_timer.wait_time = randi_range(99,99)
	music_timer.start()

func play_track():
	var m = randi_range(1,3)
	if m == 1: music.stream = SYNTH_1
	if m == 2: music.stream = SYNTH_2
	if m == 3: music.stream = SYNTH_3
	music.play()
	
