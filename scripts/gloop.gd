extends BaseCreature
class_name Gloop

func _ready():
	speed = 80
	energy_drain_rate = 0.7
	water_drain_rate = 1.0  # Slower drain — thrives longer without refills
	super._ready()
