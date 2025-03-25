extends BaseCreature
class_name Gloop

func _ready():
	speed = 70
	energy_drain_rate = 0.6
	super._ready()  # Keeps Dave's default logic while adjusting stats
