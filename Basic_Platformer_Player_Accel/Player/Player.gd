extends KinematicBody2D


const UP    = Vector2(0, -1)
const GRAVITY = 25
const MAX_SPEED = 150
const ACCELERATION = 25
const JUMP_HEIGHT = -400

enum {IDLE, WALK, JUMP, DEAD}

var state
var anim
var new_anim
var motion = Vector2()


func _ready():
	change_state(IDLE)
	
	
func _physics_process(delta):
	if position.y > 500:
		change_state(DEAD)
		
	motion.y += GRAVITY
	
	get_input()
	
	#match animation oi current state
	if new_anim != anim:
		anim = new_anim
		$Anim.play(anim)
		
	#move the player
	motion = move_and_slide(motion, UP)
	
	if state == JUMP and is_on_floor():
		change_state(IDLE)
		
	if state == JUMP and motion.y > 0:
		new_anim = "jump_down"
		
		
		
func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			new_anim = "idle"
		WALK:
			new_anim = "walk"
		JUMP:
			new_anim = "jump_up"
		DEAD:
			queue_free()
			
			
func get_input():
	var right = Input.is_action_pressed("ui_right")
	var left  = Input.is_action_pressed("ui_left")
	var jump  = Input.is_action_just_pressed("ui_up")
	
	if right:
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
		$Sprite.flip_h = false
	if left:
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		#motion.x -= ACCELERATION
		$Sprite.flip_h = true
	#if not pressing any key, lerp motion to 0 (friction)
	if not left and not right:
		motion.x = lerp(motion.x, 0, 0.2)
		
	#transition from idle/walk to jump
	if jump and is_on_floor():
		change_state(JUMP)
		motion.y = JUMP_HEIGHT
	#transition for idle to walk
	if state == IDLE and motion.x != 0:
		change_state(WALK)
	#transition from walk to idle
	if state == WALK and motion.x == 0:
		change_state(IDLE)
	if state in [IDLE, WALK] and !is_on_floor():
		change_state(JUMP)
	#friction when jumping
	if state == JUMP and !is_on_floor():
		motion.x = lerp(motion.x, 0, 0.05)
		