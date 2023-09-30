extends Node3D

@onready var crane_root = $CraneRoot
#@onready var pin_joint_3d = $PinJoint3D
@onready var pin_joint_3d = $Generic6DOFJoint3D
@onready var decal = $Decal


const moveForce: float = 500.0;
const brakeForce: float = 1000.0;
const vertMoveForce: float = 1000.0;
const vertBrakeForce: float = 1500.0;
const rotateTorque: float = 300.0;

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_joint();

func _process(delta):
	decal.position = crane_root.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var move_vec: Vector2 = Input.get_vector("left", "right", "up", "down");
	var vert_move: float = Input.get_axis("lower", "raise");
	var vert_scaled: float = lerp(-1.0, 1.5, (vert_move + 1.0) / 2);
	var rot_move: float = Input.get_axis("rotate_right", "rotate_left");
	var force_vec: Vector3 = Vector3.ZERO;
	var velo_vec: Vector3 = crane_root.get_linear_velocity();
	var normal_velo_vec: Vector3 = velo_vec.normalized();
	
	var torque_vec: Vector3 = crane_root.get_angular_velocity();
	var normal_torque_vec: Vector3 = torque_vec.normalized();
	var torque_force: Vector3 = Vector3.ZERO;
	
	var force: float = brakeForce;
	
	if move_vec.x == 0.0:
		force_vec.x = -normal_velo_vec.x * brakeForce;
	else:
		force_vec.x = move_vec.x * moveForce;
	
	if move_vec.y == 0.0:
		force_vec.z = -normal_velo_vec.z * brakeForce;
	else:
		force_vec.z = move_vec.y * moveForce;
	
	
	var weightMultiplier: float = 1.0 if pin_joint_3d.node_b == null else 1.5;
	if vert_move == 0.0:
		var normal_velo: float = lerp(-1.0, 1.0, (normal_velo_vec.y + 1.0) / 2.0)
		if normal_velo_vec.y > 0.0:
			force_vec.y = -1 * vertBrakeForce * weightMultiplier;
		elif normal_velo_vec.y < 0.0:
			force_vec.y = 1 * vertBrakeForce * weightMultiplier;
	else:
		force_vec.y = vert_scaled * vertMoveForce * weightMultiplier;
	
	#force_vec.y -= diff * (weightMultiplier - 1.0) * vertBrakeForce;
			
		
	if rot_move == 0.0:
		torque_force.y = -normal_torque_vec.y * rotateTorque;
	else:
		torque_force.y = rot_move * rotateTorque;
	
#	if velo_vec.length() < 50.0 && move_vec.length_squared() > 0:
#		force_vec = Vector3(move_vec.x, 0, move_vec.y)
#		force = moveForce;
#	else:
#		force_vec = -velo_vec.normalized()
	
	#crane_root.move_and_collide(Vector3(move_vec.x, 0, move_vec.y));
	crane_root.apply_central_force(force_vec);
	crane_root.apply_torque(torque_force);
	#pin_joint_3d.position = crane_root.position;
	
func attach(cont: Node3D):
	#remove_child(crane_head);
	#cont.attach(crane_head);
	pin_joint_3d.node_a = crane_root.get_path();
	pin_joint_3d.node_b = cont.rigid_body_3d.get_path();

func detach(cont: Node3D):
	reset_joint();
	#var pos = crane_head.global_position;
	#cont.detach(crane_head);
	#add_child(crane_head);
	#crane_head.global_position = pos;
	crane_root.angular_velocity = Vector3.ZERO;

func reset_joint():
	pin_joint_3d.node_a = NodePath("");
	pin_joint_3d.node_b = NodePath("");
