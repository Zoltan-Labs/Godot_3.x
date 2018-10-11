extends KinematicBody2D


var speed = 500


func _physics_process(delta):
	var move_dir = Vector2()
	var key_up = Input.is_action_pressed("ui_up")
	var key_down = Input.is_action_pressed("ui_down")
	var key_left = Input.is_action_pressed("ui_left")
	var key_right = Input.is_action_pressed("ui_right")
	
	if key_up:
		move_dir.y = -speed
	if key_down:
		move_dir.y = speed
	if key_left:
		move_dir.x = -speed
	if key_right:
		move_dir.x = speed
		
		
	move_and_slide(move_dir)
	