extends SpringArm3D

@export var sensitivity := 1
@export var up_angle := -75.0
@export var lim1_angle := -40.0
@export var lim2_angle := 0.0
@export var down_angle := 45.0
@export var up_dist := 3.0
@export var med_dist := 2.5
@export var down_dist := 0.8

func _ready() -> void:
	set_as_top_level(true)


func _process(_delta: float) -> void:
	var look_rotation = Vector2.ZERO
	look_rotation.x = Input.get_action_strength("look_up") - Input.get_action_strength("look_down")
	look_rotation.y = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	
	rotation_degrees.x -= look_rotation.x * sensitivity
	rotation_degrees.x = clamp(rotation_degrees.x,up_angle,down_angle)
		
	rotation_degrees.y -= look_rotation.y * sensitivity* 2
	rotation_degrees.y = wrapf(rotation_degrees.y,-0.0,360.0)
	
	
	var a1 := (up_dist-med_dist)/pow(up_angle-lim1_angle,2)
	var b1 := -2*a1*lim1_angle
	var c1 := med_dist+a1*pow(lim1_angle,2)
	
	var a2 := (down_dist-med_dist)/pow(down_angle-lim2_angle,2)
	var b2 := -2*a2*lim2_angle
	var c2 := med_dist+a2*pow(lim2_angle,2)
	
	if rotation_degrees.x < lim1_angle:
		spring_length = a1*pow(rotation_degrees.x,2)+b1*rotation_degrees.x+c1
	elif rotation_degrees.x > lim2_angle:
		spring_length = a2*pow(rotation_degrees.x,2)+b2*rotation_degrees.x+c2
	elif spring_length!=med_dist:
		spring_length=med_dist

