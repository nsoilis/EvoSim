extends CharacterBody2D
class_name BaseCreature  # This makes it easier to inherit from

@export var speed: float = 100.0
@export var energy: float = 100.0
@export var energy_drain_rate: float = 1.0
@export var water: float = 100.0
@export var water_drain_rate: float = 1.5  # Decreases at the same rate for all
@export var center_weight: float = 0.5  # Adjust this for stronger/weaker pull


var direction = Vector2.ZERO
var screen_size = Vector2.ZERO  # Tracks screen size for bounds
var direction_timer = null  # Timer reference for dynamic timing

# Reference for the water bar
@onready var water_bar = $WaterBar  # ProgressBar for visualizing water level
@onready var energy_bar = $EnergyBar

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

	if collision:
		global_position -= direction * 2.0
		direction = -direction

	# Wrap-Around Movement Logic
	if global_position.x < 0:  # Left edge → Teleport to right
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:  # Right edge → Teleport to left
		global_position.x = 0

	if global_position.y < 0:  # Top edge → Teleport to bottom
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:  # Bottom edge → Teleport to top
		global_position.y = 0


	# Energy drain over time
	energy -= energy_drain_rate * delta
	water -= water_drain_rate * delta
	
	# Update Water and Energy Bar
	update_water_bar()
	update_energy_bar()

# Picks a new random direction for movement
func set_random_direction():
	var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

	# Opportunistic Water Prioritization
	var water_sources = get_tree().get_nodes_in_group("water_sources")
	if water_sources.size() > 0:
		var nearest_water = find_nearest_water(water_sources)
		var distance_to_water = global_position.distance_to(nearest_water.global_position)

		# Prioritize water aggressively if water is < 50
		if water < 50:
			var to_water = (nearest_water.global_position - global_position).normalized()
			direction = to_water
			return

		# Opportunistic behavior: Prioritize water if water < 80 AND they're nearby
		elif water < 80 and distance_to_water < 200:
			var to_water = (nearest_water.global_position - global_position).normalized()

			# Blend random movement with slight bias toward the water
			var water_weight = clamp(1.0 - (water / 100.0), 0.2, 0.5)
			direction = (random_direction * (1.0 - water_weight)) + (to_water * water_weight)
			direction = direction.normalized()
			return

	# Default random wandering if no conditions apply
	direction = random_direction
	direction = direction.normalized()

# Find the closest water source
func find_nearest_water(water_sources):
	var nearest_water = water_sources[0]
	var shortest_distance = global_position.distance_to(nearest_water.global_position)

	for water in water_sources:
		var distance = global_position.distance_to(water.global_position)
		if distance < shortest_distance:
			nearest_water = water
			shortest_distance = distance

	return nearest_water


# Randomizes the timer's interval between 1.0 and 2.0 seconds
func set_random_timer():
	direction_timer.wait_time = randf_range(0.5, 1.5)
	direction_timer.start()

# Triggered when the timer runs out
func on_direction_timer_timeout():
	set_random_direction()
	set_random_timer()  # Restart with a new random time
	
# Water Bar Update Logic
func update_water_bar():
	if water_bar:
		water_bar.value = max(0, water)  # Ensures no negative values
		
# Energy Bar Update Logic
func update_energy_bar():
	if energy_bar:
		energy_bar.value = max(0, energy)
		
func refill_water():
	water = 100.0
	update_water_bar()

func refill_energy(amount: int):
	energy = min(100.0, energy + amount)
	update_energy_bar()
