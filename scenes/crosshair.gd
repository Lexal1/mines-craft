extends Line2D

@export var max_points: int = 300      # Total horizontal resolution
@export var width_pixels: float = 15.0 # Total width of the monitor
@export var scroll_speed: float = 1.5  # Speed of the wave movement
@export var pulse_rate: float = 2.5    # Beats per second (Hz)
@export var amplitude: float = 12.0   # Height of the main QRS spike

var time_passed: float = 0.0

func _ready() -> void:
	# Pre-populate the line with empty points spread horizontally
	for i in range(max_points):
		var x_pos = (float(i) / max_points) * width_pixels
		add_point(Vector2(x_pos, 0))

func _process(delta: float) -> void:
	time_passed += delta * scroll_speed
	
	for i in range(max_points):
		var point_pos = get_point_position(i)
		# Calculate a unique local time offset for each horizontal coordinate
		# Shifting by point_pos.x creates a continuous traveling wave
		var local_time = time_passed - (point_pos.x * 0.02)
		
		# Sample the heartbeat function
		point_pos.y = calculate_heartbeat_y(local_time)
		set_point_position(i, point_pos)

# Analytical function emulating a full P-Q-R-S-T cardiac cycle
func calculate_heartbeat_y(t: float) -> float:
	# Wrap time to create a repeating pulse cycle
	var phase = fmod(t * pulse_rate, 2.0 * PI)
	var y = 0.0
	
	# 1. P Wave (Small initial bump)
	y += 0.15 * exp(-pow((phase - 1.0) / 0.15, 2))
	
	# 2. Q Wave (Small dip right before the spike)
	y -= 0.20 * exp(-pow((phase - 1.4) / 0.05, 2))
	
	# 3. R Wave (The massive main vertical heartbeat spike)
	y += 1.00 * exp(-pow((phase - 1.5) / 0.04, 2))
	
	# 4. S Wave (Sharp dip right after the spike)
	y -= 0.35 * exp(-pow((phase - 1.6) / 0.05, 2))
	
	# 5. T Wave (Medium recovery bump)
	y += 0.30 * exp(-pow((phase - 2.2) / 0.25, 2))
	
	# Invert because Godot's Y-axis points downward (Negative moves up)
	return -y * amplitude
