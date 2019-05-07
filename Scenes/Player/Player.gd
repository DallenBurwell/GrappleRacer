extends KinematicBody2D

var vel: Vector2

export var RUN_ACCEL: float = 100.0
export var FRICTION: float = 0.99
export var MAX_RUN_SPEED: float = 500.0
export var JUMP_FORCE: float = 200.0
export var GRAV: float = 10.0
const FLOOR_NORMAL: Vector2 = Vector2(0,-1)

onready var anim = $Anim

var state

enum STATES {
	IDLE,
	RUNNING,
	JUMPING,
}

func _ready():
	vel = Vector2(0,0)
	state = STATES.IDLE

func _physics_process(delta):
	if is_on_floor():
		vel.y = 0
	
	set_anim()
	
	match state:
		STATES.IDLE:
			if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
				state = STATES.RUNNING
			if Input.is_action_pressed("ui_up") and is_on_floor():
				jump()
				state = STATES.JUMPING
			if not is_on_floor():
				fall()
		STATES.RUNNING, STATES.JUMPING:
			move()
			match state:
				STATES.RUNNING:
					if vel.x == 0:
						state = STATES.IDLE
					elif Input.is_action_pressed("ui_up") and is_on_floor():
						jump()
						state = STATES.JUMPING
				STATES.JUMPING:
					if is_on_floor():
						if vel.x != 0:
							state = STATES.RUNNING
						else:
							state = STATES.IDLE
					else:
						fall()

func move():
	var accel = Vector2(0,0)
	
	if Input.is_action_pressed("ui_left"):
		accel.x -= RUN_ACCEL
	if Input.is_action_pressed("ui_right"):
		accel.x += RUN_ACCEL
	if accel.x == 0 && abs(vel.x) > 1:
		accel.x = -FRICTION * vel.x
	
	if abs(vel.x) < 1:
		vel.x = 0
	
	vel += accel
	
	vel.x = clamp(vel.x, -MAX_RUN_SPEED, MAX_RUN_SPEED)
	
	move_and_slide(vel, FLOOR_NORMAL)

func jump():
	vel.y -= JUMP_FORCE
	move_and_slide(vel, FLOOR_NORMAL)

func fall():
	vel.y += GRAV
	move_and_slide(vel, FLOOR_NORMAL)

func set_anim():
	anim.flip_h = vel.x < 0
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