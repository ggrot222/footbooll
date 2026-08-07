class_name Player
extends CharacterBody2D

const DURATION_TACKLE := 200 # Длительность подката в мс

enum ControlScheme {CPU, P1, P2}
enum State {MOVING, TACKLING}

@export var control_scheme : ControlScheme = ControlScheme.P1
@export var speed : float = 200.0
@export var tackle_speed_multiplier : float = 1.6

@onready var animation_player : AnimationPlayer = %AnimationPlayer
@onready var player_sprite : Sprite2D = $PlayerSprite

var heading := Vector2.RIGHT
var state := State.MOVING
var time_start_tackle := 0

func _physics_process(_delta: float) -> void:
	if control_scheme == ControlScheme.CPU:
		pass
	else:
		match state:
			State.MOVING:
				handle_human_movement()
				# Проверяем нажатие кнопки подката
				if KeyUtils.is_action_just_pressed(control_scheme, KeyUtils.Action.SHOOT):
					state = State.TACKLING
					time_start_tackle = Time.get_ticks_msec()
			
			State.TACKLING:
				handle_tackle_movement()

	set_movement_animation()
	set_heading()
	flip_sprites()
	move_and_slide()

func handle_human_movement() -> void:
	var direction := KeyUtils.get_input_vector(control_scheme)
	velocity = direction * speed

func handle_tackle_movement() -> void:
	# Скольжение в сторону взгляда
	velocity = heading * (speed * tackle_speed_multiplier)
	
	# Возврат в обычное состояние по истечении времени
	if Time.get_ticks_msec() - time_start_tackle >= DURATION_TACKLE:
		state = State.MOVING

func set_movement_animation() -> void:
	if state == State.TACKLING:
		if animation_player.has_animation("tackle"):
			animation_player.play("tackle")
	elif velocity.length() > 0:
		if animation_player.has_animation("run"):
			animation_player.play("run")
	else:
		if animation_player.has_animation("idle"):
			animation_player.play("idle")

func set_heading() -> void:
	if state == State.MOVING:
		if velocity.x > 0:
			heading = Vector2.RIGHT
		elif velocity.x < 0:
			heading = Vector2.LEFT

func flip_sprites() -> void:
	if heading == Vector2.RIGHT:
		player_sprite.flip_h = false
	elif heading == Vector2.LEFT:
		player_sprite.flip_h = true
