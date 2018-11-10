extends KinematicBody2D


const UP    = Vector2(0, -1)
const MAXSPEED_Y = 400

enum {IDLE, WALK, JUMP, DEAD, CLIMB_UP, CLIMB_DOWN, IDLE_ON_LADDER}

var state
var anim
var new_anim
var walk_speed = 150
var jump_speed = -400
var gravity = 25
var motion = Vector2()
# Ladder Vars
var is_under_ladder  = false
var is_top_ladder = false
var is_standing_top_ladder = false
var is_bottom_ladder = false
var is_on_ladder = false


func _ready():
	change_state(IDLE)
	
	
func _physics_process(delta):
	if position.y > 500:
		change_state(DEAD)
		
	motion.y += gravity
	
	# check the tile names inside the tilemap "Ladder"
	is_under_ladder  = get_tile_on_position(position.x, position.y - 16) == "LadderPiece"
	is_on_ladder  = get_tile_on_position(position.x, position.y) == "LadderPiece"
	is_top_ladder = get_tile_on_position(position.x, position.y - 16) == "TopPlatform2"
	is_standing_top_ladder = get_tile_on_position(position.x, position.y + 16) == "TopPlatform2"
	is_bottom_ladder = get_tile_on_position(position.x, position.y + 2) == "LadderBottom"
	
	get_input()
	
	#match animation oi current state
	if new_anim != anim:
		anim = new_anim
		$Anim.play(anim)
		
		
	motion.y = max(motion.y, -MAXSPEED_Y)

	#move the player
	motion = move_and_slide(motion, UP)
	
	if state == JUMP and is_on_floor():
		change_state(IDLE)
		
	if state == JUMP and motion.y > 0:
		new_anim = "jump_down"
		
	if is_bottom_ladder:
		change_state(IDLE)
		

	
	
func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			gravity = 25
			new_anim = "idle"
		WALK:
			new_anim = "walk"
		JUMP:
			new_anim = "jump_up"
		CLIMB_UP:
			new_anim = "on_ladder"
			gravity = 0
			motion.y = -100
		CLIMB_DOWN:
			new_anim = "on_ladder"
			gravity = 0
			motion.y = 100
		IDLE_ON_LADDER:
			new_anim = "on_ladder"
			gravity = 0
			motion.y = 0
		DEAD:
			queue_free()
			
			
func get_input():
	var right = Input.is_action_pressed("ui_right")
	var left  = Input.is_action_pressed("ui_left")
	var jump  = Input.is_action_just_pressed("ui_jump")
	var up    = Input.is_action_pressed("ui_up")
	var down  = Input.is_action_pressed("ui_down")
	
	
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
		
	# Ladder Stuff
	# when player touches the top one way platform, jumps up 
	if up and is_top_ladder:
		motion.y += -50
		
	# when player is standing on platform above the ladder and presses down
	if down and is_standing_top_ladder:
		position.y += 2
		change_state(CLIMB_DOWN)
		
	# when the next tile above the player position is a ladder tile, and pressed up
	if up and is_under_ladder:
		change_state(CLIMB_UP)

	# not pressing up and down, on the ladder, and not on the floor
	if !up and !down and is_under_ladder and !is_on_floor():
		change_state(IDLE_ON_LADDER)
		
	# pressing down, on the ladder, and not on the floor
	if down and is_under_ladder and !is_on_floor():
		change_state(CLIMB_DOWN)
		
	# transition from climb up state to idle
	if state == CLIMB_UP and is_on_floor():
		change_state(IDLE)
		
	# transition to idle state
	if !is_on_ladder:
		change_state(IDLE)
		
		
func get_tile_on_position(x,y):
	var tilemap = get_parent().get_node("Ladder")
	if not tilemap == null:
		var map_pos = tilemap.world_to_map(Vector2(x,y))
		var id = tilemap.get_cellv(map_pos)
		if id > -1:
			var tilename = tilemap.get_tileset().tile_get_name(id)
			return tilename
		else:
			return "NotOnLadder"