extends CPUParticles2D

var time_elapsed = 0

func _ready():
	# Spawn particles
	emitting = true

# Delete after particles anim
func _process(delta):
	time_elapsed += delta
	if time_elapsed >= lifetime:
		queue_free()
