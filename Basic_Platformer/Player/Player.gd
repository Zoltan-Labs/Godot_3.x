extends KinematicBody2D


const UP    = Vector2(0, -1)

enum {IDLE, WALK, JUMP, DEAD}

var state
var anim
var new_anim
var walk_speed = 150
var jump_speed = -400
var gravity = 25
var motion = Vector2()


func _ready():
	change_state(IDLE)
	
	
func _physics_process(delta):
	if position.y > 500:
		change_state(DEAD)
		
	motion.y += gravity
	
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
	var left = Input.is_action_pressed("ui_left")
	var jump = Input.is_action_just_pressed("ui_up")
	
	motion.x = 0
	
	if right:
		motion.x += walk_speed
		$Sprite.flip_h = false
	if left:
		motion.x -= walk_speed
		$Sprite.flip_h = true
		
	#transition from idle/walk to jump
	if jump and is_on_floor():
		change_state(JUMP)
		motion.y += jump_speed
	#transition for idle to walk
	if state == IDLE and motion.x != 0:
		change_state(WALK)
	#transition from walk to idle
	if state == WALK and motion.x == 0:
		change_state(IDLE)
	if state in [IDLE, WALK] and !is_on_floor():
		change_state(JUMP)

		
	