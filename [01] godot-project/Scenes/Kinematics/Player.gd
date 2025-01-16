extends CharacterBody3D

@export var walking_speed := 2
@export var running_speed := 5.2
@export var mass := 70.0 # (float, 50,120,5)
@export var jump_strength := 10.0
@export var gravity := 35

@onready var _spring_arm : SpringArm3D = $SpringArm
@onready var _model : Node3D = $Mass

@onready var _faceCube := $Mass/Facing
@onready var _velCube := $Velocity
@onready var _focCube := $Focus

@onready var _MainCamPos := $SpringArm/MainCamPos
@onready var _VisionCamPos := $FaceCamPos

@onready var _DownRays := $Raycasts/LedgeStopper/DownRays.get_children()
@onready var _LedgeFinders := $Raycasts/LedgeStopper/LedgeFinders.get_children()



# Maybe use for running, walking is immediate, or changing dir abruptly
var reaction_time = 0.8 * (mass-50)/70 + 0.4

var _velocity := Vector3.ZERO
var _snap_vector := Vector3.DOWN
var grab_points : Array = []

var can_jump := true
var can_move := true
var is_on_edge := false



func _ready() -> void:
	$Camera.move_cam(_spring_arm.position+_MainCamPos.position,_spring_arm.rotation+_MainCamPos.rotation)
	_velCube.set_as_top_level(true)
	_focCube.set_as_top_level(true)






func _physics_process(delta: float) -> void:
	grab_points 	= get_grab_points()
	
	if is_on_edge:
		print(grab_points.size())
	
	var move_direction	: Vector3	= get_movement()
	
	_velocity = calc_velocity(_velocity,move_direction,delta)
	
	set_velocity(_velocity)
	# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `_snap_vector`
	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(true)
	set_max_slides(4)
	set_floor_max_angle(deg_to_rad(45))
	move_and_slide()
	_velocity = velocity
	
	input_actions()
	animations()
	
	# Debug Visu
	_velCube.position = position + 0.15*Vector3(_velocity.x,0,_velocity.z) + Vector3.UP




func _process(_delta: float) -> void:
	var x = _spring_arm.rotation_degrees.x
	var offset := Vector3.ZERO
	
	if x < _spring_arm.lim1_angle:
		offset = 1*(x-_spring_arm.lim1_angle)/(_spring_arm.up_angle-_spring_arm.lim1_angle)*Vector3.FORWARD.rotated(Vector3.UP,_spring_arm.rotation.y)
	elif x > _spring_arm.lim2_angle:
		offset = 0.6*(x-_spring_arm.lim2_angle)/(_spring_arm.down_angle-_spring_arm.lim2_angle)*Vector3.UP
	
	
	# Debug Visu
	_spring_arm.position = position + Vector3.UP * 1.3 + offset
	_focCube.position = _spring_arm.position




func get_grab_points() -> Array:
	var outArr := []
	is_on_edge = false
	
	if !is_on_floor():
		pass
	
	else:
		for i in range(_DownRays.size()):
			if !_DownRays[i].is_colliding():
				is_on_edge = true
				var point = _LedgeFinders[i].get_collision_point()
				if position.distance_to(point)>0.2 and point != Vector3.ZERO:
					outArr.append(point)
	return outArr

func get_movement() -> Vector3:
	if !can_move : return Vector3.ZERO
	
	var out := Vector3(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			0,
			Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
		)
	
	
	out = out.rotated(Vector3.UP, $Camera.rotation.y)
	
	if is_on_floor() : out = out.slide(_snap_vector.normalized())
	
	if out.length() > 1 or Input.is_action_pressed("high_profile"):
		out = out.normalized()
	
	if out != Vector3.ZERO : 
		$Raycasts/LedgeStopper.rotation.y = Vector2(out.z,out.x).angle() - rotation.y
	else:
		$Raycasts/LedgeStopper.rotation.y = 0
	
	if !Input.is_action_pressed("high_profile") and is_on_edge:
		for gp in grab_points:
			if out.normalized().dot(position.direction_to(gp).normalized()) > 0:
				out = Vector3.ZERO
	return out

func calc_velocity(old_v : Vector3, move_dir : Vector3, delta : float) -> Vector3:
	var out = old_v
	if !is_on_floor() :
		out.y -= gravity * delta
	else:
		_snap_vector = -get_floor_normal()*0.2
		out.y=0
		
		if Input.is_action_just_pressed("jump") and can_jump:
			out.y = jump_strength
			_snap_vector = Vector3.ZERO
	
	
	if Input.is_action_pressed("high_profile"):
		out.x = move_dir.x * running_speed
		out.z = move_dir.z * running_speed
		if is_on_floor() and !_DownRays[0].is_colliding():
			out.y = jump_strength
			_snap_vector = Vector3.ZERO
	
	else:
		out.x = move_dir.x * walking_speed
		out.z = move_dir.z * walking_speed
	
	
	return out


func input_actions()-> void:
	
	if Input.is_action_just_pressed("vision"):
		if $Camera.state == "Main":
			$Camera.state = "Vision"
			print(rotation)
			rotation = Vector3(0,_spring_arm.rotation.y - PI,0)
			print(rotation)
		elif $Camera.state == "Vision":
			$Camera.state = "Main"
			_spring_arm.rotation = Vector3(_VisionCamPos.rotation.x,PI+rotation.y,0)
	
	if Input.is_action_just_pressed("target"):
		if $Camera.state == "Main":
			$Camera.state = "Target"
			rotation = Vector3(0,_spring_arm.rotation.y - PI,0)
	if Input.is_action_just_released("target"):
		if $Camera.state == "Target":
			$Camera.state = "Main"
			_spring_arm.rotation = Vector3(_VisionCamPos.rotation.x,PI+rotation.y,0)


func animations()-> void:
	
	if Vector2(_velocity.x,_velocity.z).length() > 0.1 and $Camera.state =="Main":
		rotation.y = Vector2(_velocity.z,_velocity.x).angle()









