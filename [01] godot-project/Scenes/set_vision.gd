extends StaticBody3D

@export var type = "normal" # (String, "normal", "target", "enemy","ally","special")

var TargMat : Material = load("res://Assets/Materials/VisionTarget.tres")
var EnemyMat : Material = load("res://Assets/Materials/VisionEnemy.tres")
var AllyMat : Material = load("res://Assets/Materials/VisionAlly.tres")
var SpecMat : Material = load("res://Assets/Materials/VisionSpecial.tres")


func _ready() -> void:
	if type=="target":
		$Vision.set_surface_override_material(0,TargMat) 
	elif type=="enemy":
		$Vision.set_surface_override_material(0,EnemyMat)  
	elif type=="ally":
		$Vision.set_surface_override_material(0,AllyMat)  
	elif type=="special":
		$Vision.set_surface_override_material(0,SpecMat) 
	
	$Vision.visible = true
