extends CharacterBody2D

@onready var health_component = $HealthComponent
@onready var invincible_frames = $InvincibleFrames
@onready var progress_bar = $ProgressBar
@onready var abillity_manager = $AbillityManager
@onready var animated_sprite_2d = $AnimatedSprite2D
var max_speed = 125
var acceleration = .15
var enemies_coolliding = 0

func _ready():
	health_component.died.connect(on_died)
	health_component.health_changed.connect(on_health_changed)
	Global.ability_upgrade_added.connect(on_ability_upgraade_added)
	health_update()

func _process(delta):
	var direction = movement_vector().normalized()
	var target_velocity = max_speed * direction
	velocity = velocity.lerp(target_velocity, acceleration)
	move_and_slide()

	if direction.x != 0 || direction.y != 0 :
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

	var face_sign = sign(direction.x)
	if face_sign != 0:
		animated_sprite_2d.scale.x = face_sign

	check_if_damaged()

func movement_vector():
	var movement_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var movement_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(movement_x, movement_y)

func check_if_damaged():

	if enemies_coolliding == 0 or not invincible_frames.is_stopped():
		return 

	health_component.take_damage(1)
	invincible_frames.start()

func health_update():
	progress_bar.value = health_component.get_health_value()

func _on_player_hurt_box_area_entered(area):
	enemies_coolliding += 1

func _on_player_hurt_box_area_exited(area):

	enemies_coolliding = max(0, enemies_coolliding - 1) 
func on_died():
	queue_free()

func on_health_changed():
	health_update()

func _on_invincible_frames_timeout():
	check_if_damaged() 

func on_ability_upgraade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if not upgrade is NewAbility:
		return

	var new_ability = upgrade as NewAbility
	abillity_manager.add_child(new_ability.new_ability_scene.instantiate())
