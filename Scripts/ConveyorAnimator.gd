extends Node3D

@onready var conveyor = $Conveyor

@export
var uv_scale_factor: = 1.0;
@export
var speed: = 1.0;

var mat: StandardMaterial3D;
var last_scale: Vector3 = Vector3.ZERO;

# Called when the node enters the scene tree for the first time.
func _ready():
	mat = conveyor.get_surface_override_material(1);
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if last_scale != scale:
		uv_scale_factor = 1.0 / mat.uv1_scale.y;
		mat.uv1_scale = Vector3(mat.uv1_scale.x, scale.z * uv_scale_factor, mat.uv1_scale.z);
		last_scale = scale;
	mat.uv1_offset += Vector3.UP * delta * speed;
