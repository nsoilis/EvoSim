extends CharacterBody2D

@export var speed: float = 100.0
@export var energy: float = 100.0
@export var energy_drain_rate: float = 1.0
@export var center_weight: float = 0.5  # Adjust this for stronger/weaker pull

var direction = Vector2.ZERO
var screen_size = Vector2.ZERO  # Tracks screen size for bounds
var direction_timer = null  # Timer reference for dynamic timing

func _ready():
	screen_size = get_viewport_rect().size
	set_random_direction()

	# Timer to control direction changes
	direction_timer = Timer.new()
	direction_timer.autostart = true
	direction_timer.timeout.connect(on_direction_timer_timeout)
	add_child(direction_timer)

	# Set initial randomized time for direction changes
	set_random_timer()

func _physics_process(delta):
	if energy <= 0:
		queue_free()  # Dies when out of energy
		return

	# Move in the set direction
	velocity = direction * speed
	var collision = move_and_collide(velocity * delta)

	# Collision Fix: Reverse direction instead of randomizing
	if collision:
		# Micro-Teleport a tiny step back to prevent sticking
		global_position -= direction * 2.0  # Small, almost invisible nudge
		# Reverse direction for smoother movement
		direction = -direction

	# Keep creature within screen bounds
	global_position.x = clamp(global_position.x, 0, screen_size.x)
	global_position.y = clamp(global_position.y, 0, screen_size.y)

	# Energy drain over time
	energy -= energy_drain_rate * delta

# Picks a new random direction for movement
func set_random_direction():
	var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

	# Calculate direction toward center
	var to_center = (screen_size / 2 - global_position).normalized()

	# Blend the random direction and the center direction
	direction = (random_direction * (1.0 - center_weight)) + (to_center * center_weight)
	direction = direction.normalized()

# Randomizes the timer's interval between 1.0 and 2.0 seconds
func set_random_timer():
	direction_timer.wait_time = randf_range(1.0, 2.0)
	direction_timer.start()

# Triggered when the timer runs out
func on_direction_timer_timeout():
	set_random_direction()
	set_random_timer()  # Restart with a new random time
