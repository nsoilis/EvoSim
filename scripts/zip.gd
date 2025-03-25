extends BaseCreature
class_name Zip

func _ready():
	speed = 130
	energy_drain_rate = 1.5
	water_drain_rate = 2.0  # Faster drain due to higher speed
	super._ready()
