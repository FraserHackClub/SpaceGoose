extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var confetti_particles = $GPUParticles2D

func _ready():
	# Ensure the particle system is properly configured
	if confetti_particles:
		confetti_particles.emitting = false
		
		# Create and configure the particle material
		var particle_material = ParticleProcessMaterial.new()
		
		# Set particle properties
		particle_material.spread = 360.0  # Full circle explosion
		particle_material.initial_velocity_min = 100.0
		particle_material.initial_velocity_max = 200.0
		
		# Set lifetime directly as a float value
		particle_material.lifetime = 1.25  # Average lifetime of particles
		
		# Set gravity and scale
		particle_material.gravity = Vector3(0, 98, 0)
		particle_material.scale = 1.0
		
		# Assign the material to the particles
		confetti_particles.process_material = particle_material
		
		# Configure particle system
		confetti_particles.amount = 100  # Number of particles
		confetti_particles.explosiveness = 1.0  # Instant explosion
	
	# Connect the animation_changed signal to detect animation changes
	if animated_sprite:
		animated_sprite.connect("animation_changed", Callable(self, "_on_animation_changed"))

func _on_animation_changed():
	# Check if the new animation is "egg"
	if animated_sprite.animation == "egg":
		if confetti_particles:
			confetti_particles.emitting = true
			activate_color_changing_confetti()
	else:
		if confetti_particles:
			confetti_particles.emitting = false

func activate_color_changing_confetti():
	# Create a gradient with multiple colors for the confetti
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color.RED)
	gradient.add_point(0.25, Color.YELLOW)
	gradient.add_point(0.5, Color.GREEN)
	gradient.add_point(0.75, Color.BLUE)
	gradient.add_point(1.0, Color.PURPLE)
	
	# Apply the gradient to the particle material
	if confetti_particles and confetti_particles.process_material is ParticleProcessMaterial:
		confetti_particles.process_material.color_ramp = gradient
