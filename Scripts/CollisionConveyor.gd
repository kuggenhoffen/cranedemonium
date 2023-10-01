extends RigidBody3D

var bodies: = {}

var direction: Vector3;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	direction = transform.basis.x;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	for path in bodies:
		var rb: RigidBody3D = bodies[path];
		var dot: float = rb.linear_velocity.dot(direction);
		if dot < 5.0:
			var force: float = lerp(1000.0, 200.0, dot / 5.0);
			rb.apply_force(direction * force);
		

func _on_body_entered(body: Node3D):
	if !bodies.has(body.get_path()):
		bodies[body.get_path()] = body;


func _on_body_exited(body):
	bodies.erase(body.get_path());
