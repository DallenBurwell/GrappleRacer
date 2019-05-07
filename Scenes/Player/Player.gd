extends KinematicBody2D

var vel: Vector2

export var RUN_ACCEL: float = 100.0
export var FRICTION: float = 0.9
export var MAX_RUN_SPEED: float = 500.0
export var JUMP_FORCE: float = 400.0
export var GRAV: float = 10.0
const FLOOR_NORMAL: Vector2 = Vector2(0,-1)

onready var anim = $Anim
onready var floor_ray: RayCast2D = $Detections/Floor
onready var left_ray = $Detections/Left
onready var right_ray = $Detections/Right
onready var line = $Detections/Line2D

var state

enum STATES {
	IDLE,
	RUNNING,
	JUMPING,
}

func _ready():
	vel = Vector2(0,0)
	
	change_state_to("IDLE")

func _physics_process(delta):
	
#	if is_on_floor():
#		vel.y = 0
	
	set_anim()
	
	
	match state:
		STATES.IDLE:
			if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
				change_state_to("RUNNING")
			if Input.is_action_pressed("ui_up") and is_on_floor():
				jump(delta)
				change_state_to("JUMPING")
				
				
		STATES.RUNNING, STATES.JUMPING:
			move(delta)
			
			match state:
				STATES.RUNNING:
					if vel.x == 0 and is_on_floor():
						change_state_to("IDLE")
					elif Input.is_action_pressed("ui_up") and is_on_floor():
						jump(delta)
						change_state_to("JUMPING")
					
				STATES.JUMPING:
					if not is_on_floor():
						fall(delta)
			
			move_and_collide(vel * delta)
	
	if not is_on_floor():
		change_state_to("JUMPING")
	else:
		if vel.x == 0:
			change_state_to("IDLE")
		else:
			change_state_to("RUNNING")

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
	
	if abs(vel.x) < 1:
		vel.x = 0
	
	vel += accel
	
	vel.x = clamp(vel.x, -MAX_RUN_SPEED, MAX_RUN_SPEED)

func is_on_floor() -> bool:
	return floor_ray.is_colliding()

func jump(delta: float):
	vel.y -= JUMP_FORCE

func fall(delta: float):
	vel.y += GRAV
	if is_on_floor():
		vel.y = 0

func set_anim():
	match state:
		STATES.IDLE:
			anim.play("idle")
		STATES.RUNNING:
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