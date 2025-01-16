extends Camera3D

@export var state = "Main": set = set_state

@export var move_time := 0.5

@onready var Spring := get_parent().get_node("SpringArm")
@onready var MainPos := get_parent().get_node("SpringArm/MainCamPos")
@onready var FacePos := get_parent().get_node("FaceCamPos")
@onready var ShouldPos := get_parent().get_node("ShouldCamPos")

@onready var _timer := $MovingTime

var origin := Vector3.ZERO
var origin_rot := Vector3.ZERO
var moving := false
var is_view_updated := true

func _ready() -> void:
	set_as_top_level(true)

func _process(_delta: float) -> void:
	if state == "Main":
		move_cam(MainPos.to_global(Vector3.ZERO),Spring.rotation)
	elif state == "Vision":
		move_cam(FacePos.to_global(Vector3.ZERO),get_parent().rotation+FacePos.rotation)
	elif state == "Target":
		move_cam(ShouldPos.to_global(Vector3.ZERO),get_parent().rotation+ShouldPos.rotation)

func move_cam(destin, rot) -> void:
	if _timer.is_stopped():
		position = destin
		rotation = rot
		if origin != Vector3.ZERO :
			origin = Vector3.ZERO
			origin_rot = Vector3.ZERO
	else:
		var step = smoothstep(0,1,1-_timer.time_left/_timer.wait_time)
		position = lerp(origin,destin,step)
		rotation = lerp(origin_rot,rot,step)
		if step > 0.5 and !is_view_updated:
			update_view()
			is_view_updated = true
	

func update_view() -> void:
	if state == "Main":
		print("Set to main")
		set_cull_mask_value(0,true)
		set_cull_mask_value(1,true)
		set_cull_mask_value(2,false)
	elif state == "Vision":
		print("Set to vision")
		set_cull_mask_value(2,true)
		set_cull_mask_value(1,false)
		set_cull_mask_value(0,false)


func set_state(value):
	if (state=="Vision" and value=="Main") or (state=="Main" and value=="Vision"):
		is_view_updated = false
		_timer.start(move_time)
	else:
		_timer.start(2.0*move_time/5.0)
	state = value
	origin = position
	origin_rot = rotation


