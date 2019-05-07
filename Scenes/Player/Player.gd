extends KinematicBody2D

var vel: Vector2

export var RUN_ACCEL: float = 100.0
export var FRICTION: float = 0.9
export var MAX_RUN_SPEED: float = 500.0
export var JUMP_FORCE: float = 900.0
export var GRAV: float = 40.0
const FLOOR_NORMAL: Vector2 = Vector2(0,-1)

onready var anim: AnimatedSprite = $Anim
onready var floor_l_ray: RayCast2D = $Detections/Floor_L
onready var floor_r_ray: RayCast2D = $Detections/Floor_R
onready var left_ray: RayCast2D = $Detections/Left
onready var right_ray: RayCast2D = $Detections/Right
onready var line: Line2D = $Detections/Line2D

var state

enum STATES {
	IDLE,
	RUNNING,
	JUMPING,
}

func _ready():
	vel = Vector2(0,0)
	
	floor_l_ray.add_exception($".")
	floor_r_ray.add_exception($".")
	
	change_state_to("IDLE")

func _physics_process(delta):
#	for i in line.get_point_count() - 1:
#		line.remove_point(i)
#
#	line.add_point(floor_l_ray.position)
#	line.add_point(floor_l_ray.position + floor_l_ray.cast_to)
	
	if is_on_floor() and state != STATES.JUMPING:
		vel.y = 0
	
	set_anim()
	
	match state:
		STATES.IDLE:
			if not is_on_floor():
				change_state_to("JUMPING")
			elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
				change_state_to("RUNNING")
			if Input.is_action_pressed("ui_up") and is_on_floor():
				jump()
				change_state_to("JUMPING")
				
		STATES.RUNNING, STATES.JUMPING:
			move(delta)
			
			match state:
				STATES.RUNNING:
					if not is_on_floor():
						change_state_to("JUMPING")
					elif Input.is_action_pressed("ui_up") and is_on_floor():
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
#		

func move(delta: float):
	var accel = Vector2(0,0)
	
	if Input.is_action_pressed("ui_left"):
		accel.x -= RUN_ACCEL
	if Input.is_action_pressed("ui_right"):
		accel.x += RUN_ACCEL
	if accel.x == 0 && abs(vel.x) > 1:
		accel.x = -FRICTION * vel.x
	
	if accel.x != 0 and (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")):
		anim.flip_h = accel.x < 0
	
	if abs(vel.x) <= 1:
		vel.x = 0
	
	vel += accel
	
	vel.x = clamp(vel.x, -MAX_RUN_SPEED, MAX_RUN_SPEED)
	
	move_and_collide(vel * delta)

func is_on_floor() -> bool:
	return floor_l_ray.is_colliding() or floor_r_ray.is_colliding()

func jump():
	vel.y -= JUMP_FORCE

func fall():
	vel.y += GRAV
	if is_on_floor():
		vel.y = 0

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