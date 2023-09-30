extends Node3D

@onready var crane_root = $CraneRoot;

var moveSpeed: float = 10.0;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var move_vec: Vector2 = Input.get_vector("left", "right", "up", "down");
	var force_vec: Vector3 = Vector3.ZERO;
	var velo_vec: Vector3 = crane_root.get_linear_velocity();
	if velo_vec.length() < 50.0 && move_vec.length_squared() > 0:
		force_vec = Vector3(move_vec.x, 0, move_vec.y)
		crane_root.move_and_collide(force_vec * moveSpeed);
