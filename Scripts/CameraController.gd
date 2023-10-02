extends Camera3D

var target: Node3D;
var offset_position: Vector3;
var start_position: Vector3;

# Called when the node enters the scene tree for the first time.
func _ready():
	start_position = global_position;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if target != null:
		var new_target_pos: Vector3 = target.global_position + offset_position;
		global_position = lerp(global_position, Vector3(new_target_pos.x, start_position.y, start_position.z), 0.1);

func set_target(new_target: Node3D):
	target = new_target;
	offset_position = global_position - new_target.global_position;
