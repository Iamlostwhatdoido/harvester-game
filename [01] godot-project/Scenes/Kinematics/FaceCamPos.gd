extends Marker3D


@export var sensitivity := 1.0
@export var up_angle := -45.0
@export var down_angle := 45.0
@export var side_angle := 45.0

@onready var Cam = get_parent().get_node("Camera")
@onready var spring = get_parent().get_node("SpringArm")

var coef := 1.0

func _process(_delta: float) -> void:
	if Cam.state == "Target" or Cam.state == "Vision":
		if Cam.state == "Target" and coef != 0.2:
			coef = 0.2
		elif Cam.state == "Vision" and coef != 1.0:
			coef = 1.0
		
		var look_rotation = Vector2.ZERO
		look_rotation.x = Input.get_action_strength("look_up") - Input.get_action_strength("look_down")
		look_rotation.y = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
		
		rotation_degrees.x -= look_rotation.x * sensitivity * coef * 2
		rotation_degrees.x = clamp(rotation_degrees.x,up_angle,down_angle)
			
		get_parent().rotation_degrees.y -= look_rotation.y * sensitivity * coef * 2.5
	else:
		rotation = Vector3(spring.rotation.x,PI,0)

