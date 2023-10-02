extends CSGBox3D

@export
var end_a: Node3D = null;

@export
var end_b: Node3D = null;

# Called when the node enters the scene tree for the first time.
func _ready():
	set_ends(end_a, end_b);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if end_a != null && end_b != null:
		var pos_a = end_a.global_position;
		var pos_b = end_b.global_position;
		var vec = pos_b - pos_a;
		var len = vec.length();
		
		transform.origin = lerp(pos_a, pos_b, 0.5);
		transform = transform.looking_at(pos_a + vec);
		size.z = len;
		
		#var rot = Quaternion(transform.basis.y, vec.normalized());
		#transform.basis = Basis(rot);
		#transform.origin = lerp(pos_a, pos_b, 0.5);
		#transform = transform.orthonormalized()
		#height = len;
		
func set_ends(a: Node3D, b: Node3D):
	end_a = a;
	end_b = b;
	if a != null && b != null:
		visible = true;
	else:
		visible = false;
	
