extends KinematicBody2D


const UP    = Vector2(0, -1)
const MAX_SPEED = 300

enum {IDLE, WALK, JUMP, DEAD}

var state
var anim
var new_anim
var walk_speed = 150
var jump_speed = -400
var gravity = 25
var motion = Vector2()
var body

var input_direction = 0
var direction = 1
var velocity = Vector2()
var acceleration = 350
var slowdown = 250
var was_on_ice = false




func _ready():
	change_state(IDLE)
	
	
func _physics_process(delta):
	if position.y > 500:
		change_state(DEAD)
		
	input_direction = 0
		
	motion.y += gravity

	get_input()
	
	
	# test if player is on ice
	if $RayGround.is_colliding():
		body = $RayGround.get_collider().name
		if body == "IceGround":
			was_on_ice = true
			if input_direction != 0:
				if velocity.x <= 0:
					direction = input_direction
					
				if direction == input_direction:
					velocity.x += acceleration * delta
				else:
					velocity.x -= acceleration * delta
			else:
				velocity.x -= slowdown * delta
				
			velocity.x = clamp(velocity.x, 0, MAX_SPEED)
			motion = Vector2(direction * velocity.x, motion.y)
		else:
			#when player was on ice and then jumps to land
			#the velocity.x takes time until it gets to direction of motion
			#by multipling by -1 the direction is set correctly
			if was_on_ice:
				velocity.x *= -1
				was_on_ice = false
	
	

	#match animation current state
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
		input_direction += 1
		motion.x += walk_speed
		$Sprite.flip_h = false
		if $RayGround.position.x < 0:
			$RayGround.position.x *= -1

	if left:
		input_direction -=1
		motion.x -= walk_speed
		$Sprite.flip_h = true
		if $RayGround.position.x > 0:
			$RayGround.position.x *= -1

			
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
		
		


				


