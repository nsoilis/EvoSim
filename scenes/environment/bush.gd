extends StaticBody2D

@export var fruit_energy: int = 15  # Energy restored per berry
@export var respawn_time: float = 8.0  # Time for berries to regrow

var berry_states = [true, true, true]  # Tracks which berries are active
var berry_cooldowns = [false, false, false]  # Tracks berries in cooldown

func _ready():
	randomize_berries()

func randomize_berries():
	# Randomly activate 1 to 3 berries
	var berry_count = randi_range(1, 3)
	for i in range(3):
		var berry_sprite = get_node("BerryPoints/Berry" + str(i + 1))
		berry_states[i] = (i < berry_count)  # Activate only the desired number
		berry_sprite.visible = berry_states[i]

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is BaseCreature:
		eat_nearby_berry(body)

func eat_nearby_berry(creature: BaseCreature):
	for i in range(3):
		if berry_states[i]:
			var berry_sprite = get_node("BerryPoints/Berry" + str(i + 1))
			berry_sprite.visible = false
			berry_states[i] = false

			creature.refill_energy(fruit_energy)
			regrow_berries()  # Now randomizes berry count during regrowth
			break

func start_berry_cooldown(index: int):
	await get_tree().create_timer(respawn_time).timeout
	berry_states[index] = true
	berry_cooldowns[index] = false  # Cooldown finished
	get_node("BerryPoints/Berry" + str(index + 1)).visible = true

func regrow_berries():
	await get_tree().create_timer(respawn_time).timeout

	# Randomly regrow 1-3 berries
	var berries_to_regrow = randi_range(1, 3)

	# Clear all berries before regrowing
	for i in range(3):
		berry_states[i] = false
		get_node("BerryPoints/Berry" + str(i + 1)).visible = false

	# Randomly pick berries to regrow
	var selected_berries = []
	while selected_berries.size() < berries_to_regrow:
		var random_index = randi() % 3
		if random_index not in selected_berries:
			selected_berries.append(random_index)

	# Activate the selected berries
	for index in selected_berries:
		berry_states[index] = true
		get_node("BerryPoints/Berry" + str(index + 1)).visible = true
