extends Camera3D

var target: Node3D;
var offsetPosition: Vector3;
var startPosition: Vector3;

# Called when the node enters the scene tree for the first time.
func _ready():
	startPosition = position;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target != null:
		global_position = target.global_position + offsetPosition
		position.y = startPosition.y;
		position.z = startPosition.z;

func set_target(new_target: Node3D):
	target = new_target;
	offsetPosition = global_position - new_target.global_position;
