extends Node


func _ready():
	$Label.visible = false

# don't forget to change in the inspector, Game Scene Pause property to "Process"
# and change the Player Scene Pause property to "Stop"
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
		
		if get_tree().paused:
			$Label.visible = true
		else:
			$Label.visible = false
		
		print("paused: ",get_tree().paused)