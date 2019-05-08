extends KinematicBody2D

var vel: Vector2

export var RUN_ACCEL: float = 100.0
export var FRICTION: float = 0.05
export var MAX_RUN_SPEED: float = 500.0
export var JUMP_FORCE: float = 500.0
export var GRAV: float = 30.0
export var GRAPPLE_SPEED: float = 100.0

onready var anim: AnimatedSprite = $Anim

onready var floor_l_ray: RayCast2D = $Detections/Floor_L
onready var floor_r_ray: RayCast2D = $Detections/Floor_R

onready var ceil_l_ray: RayCast2D = $Detections/Ceil_L
onready var ceil_r_ray: RayCast2D = $Detections/Ceil_R

onready var left_t_ray: RayCast2D = $Detections/Left_T
onready var left_b_ray: RayCast2D = $Detections/Left_B

onready var right_t_ray: RayCast2D = $Detections/Right_T
onready var right_b_ray: RayCast2D = $Detections/Right_B

onready var hook: RayCast2D = $Hook

#onready var line: Line2D = $Detections/Line2D

var state
var _delta

enum STATES {
	IDLE,
	RUNNING,
	JUMPING,
	GRAPPLING
}

func _ready():
	vel = Vector2(0,0)
	
	floor_l_ray.add_exception($".")
	floor_r_ray.add_exception($".")
	
	ceil_l_ray.add_exception($".")
	ceil_r_ray.add_exception($".")
	
	left_t_ray.add_exception($".")
	left_b_ray.add_exception($".")
	
	right_t_ray.add_exception($".")
	right_b_ray.add_exception($".")
	
	hook.add_exception($".")
	
	change_state_to("IDLE")

func _physics_process(delta):
#	for i in line.get_point_count() - 1:
#		line.remove_point(i)
#
#	line.add_point(floor_l_ray.position)
#	line.add_point(floor_l_ray.position + floor_l_ray.cast_to)
	
	_delta = delta
	set_anim()
	
	if is_on_floor() and state != STATES.JUMPING:
		vel.y = 0
	
	match state:
		STATES.IDLE:
			move()
			if not is_on_floor():
				change_state_to("JUMPING")
			elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
				change_state_to("RUNNING")
			if Input.is_action_pressed("jump") and is_on_floor():
				jump()
				change_state_to("JUMPING")
			
			
		STATES.GRAPPLING:
			grapple()
		
		STATES.RUNNING, STATES.JUMPING:
			move()
			
			match state:
				STATES.RUNNING:
					if not is_on_floor():
						change_state_to("JUMPING")
					elif Input.is_action_pressed("jump") and is_on_floor():
						jump()
						change_state_to("JUMPING")
					elif vel.x == 0:
						change_state_to("IDLE")
					
				STATES.JUMPING:
					if not is_on_floor():
						fall()
					else:
						if vel.x == 0:
							change_state_to("IDLE")
						else:
							change_state_to("RUNNING")

func move():
	var accel = Vector2(0,0)
	
	if Input.is_action_pressed("ui_left"):
		accel.x -= RUN_ACCEL
	if Input.is_action_pressed("ui_right"):
		accel.x += RUN_ACCEL
	if accel.x == 0 && abs(vel.x) > 1:
		accel.x = -FRICTION * vel.x
	
	if vel.x < 0:
		anim.flip_h = true
	elif vel.x > 0:
		anim.flip_h = false
	
	if abs(vel.x) <= 1:
		vel.x = 0
	
	vel += accel
	
	clamp_vel()
	
	move_and_collide(vel * _delta)
	
	if is_on_ceiling():
		vel.y = 0

func is_on_floor() -> bool:
	return floor_l_ray.is_colliding() or floor_r_ray.is_colliding()

func is_on_ceiling() -> bool:
	return ceil_l_ray.is_colliding() or ceil_r_ray.is_colliding()

func is_on_right_wall() -> bool:
	return right_t_ray.is_colliding() or right_b_ray.is_colliding()

func is_on_left_wall() -> bool:
	return left_t_ray.is_colliding() or left_b_ray.is_colliding()

func clamp_vel():
	var min_x_speed = 0 if is_on_left_wall() else -MAX_RUN_SPEED
	var max_x_speed = 0 if is_on_right_wall() else MAX_RUN_SPEED
	
	vel.x = clamp(vel.x, min_x_speed, max_x_speed)

func jump():
	vel.y -= JUMP_FORCE

func fall():
	vel.y += GRAV
	if is_on_floor():
		vel.y = 0

func grapple():
	var to_hook = hook.hooked_at - global_position
	vel += to_hook.normalized() * GRAPPLE_SPEED
	
	clamp_vel()
	
	if is_on_ceiling() or is_on_floor():
		vel.y = 0
	
	move_and_collide(vel * _delta)

func set_anim():
	match state:
		STATES.IDLE:
			anim.play("idle")
		STATES.RUNNING:
			if abs(vel.x) > 1:
				anim.play("running")
		STATES.JUMPING:
			if vel.y < 0:
				anim.play("jumping")
			else:
				anim.play("falling")

func change_state_to(to_state: String):
	match to_state:
		"IDLE":
			state = STATES.IDLE
		"RUNNING":
			state = STATES.RUNNING
		"JUMPING":
			state = STATES.JUMPING
		"GRAPPLING":
			state = STATES.GRAPPLING

func _on_Hook_hooked():
	change_state_to("GRAPPLING")
	var to_hook = hook.hooked_at - global_position
	vel += to_hook.normalized() * GRAPPLE_SPEED
	
	move_and_collide(vel * _delta)


func _on_Hook_unhooked():
	change_state_to("IDLE")
