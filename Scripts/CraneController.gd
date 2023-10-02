extends Node3D

@onready var crane_root = $CraneRoot
@onready var pin_joint_3d = $Generic6DOFJoint3D
@onready var decal = $Decal
@onready var hook = $hook
@onready var crane_moving_struss_x = $crane_moving_struss_x
@onready var crane_moving_struss_y = $crane_moving_struss_y

@export
var ropes: Array[Node3D];


const moveForce: float = 2000.0;
const brakeForce: float = 5000.0;
const vertMoveForce: float = 1000.0;
const vertBrakeForce: float = 1500.0;
const rotateTorque: float = 300.0;

var last_force_vec: Vector3 = Vector3.ZERO;
var input_enabled: bool = false;

var hook_offset: Vector3;

var attached_container: Node3D = null;
var attachable_container: Node3D = null;

var input_listener: Callable;

# Called when the node enters the scene tree for the first time.
func _ready():
	hook_offset = crane_root.position - hook.position;
	reset_joint();

func _process(_delta):
	decal.position = crane_root.position
	hook.position = crane_root.position - hook_offset;
	hook.rotation.y = crane_root.rotation.y;
	crane_moving_struss_x.global_position.x = crane_root.global_position.x;
	crane_moving_struss_y.global_position = Vector3(crane_root.global_position.x, crane_moving_struss_y.global_position.y, crane_root.global_position.z);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if not input_enabled:
		return;
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
		
	if input_listener.is_valid():
		input_listener.call(move_vec, vert_move, rot_move);
		
	var velo = velo_vec.length();
	if move_vec.x == 0.0:
		force_vec.x = -normal_velo_vec.x * brakeForce;
		if velo < 5.0:
			force_vec.x = lerp(0.0, force_vec.x, velo/5);
	else:
		force_vec.x = move_vec.x * moveForce;
	
	if move_vec.y == 0.0:
		force_vec.z = -normal_velo_vec.z * brakeForce;
		if velo < 5.0:
			force_vec.z = lerp(0.0, force_vec.z, velo/5);
	else:
		force_vec.z = move_vec.y * moveForce;
	
	var weightMultiplier: float = 1.0 if pin_joint_3d.node_b == null else 1.5;
	if vert_move == 0.0:
		if normal_velo_vec.y > 0.0:
			force_vec.y = -1 * vertBrakeForce * weightMultiplier;
		elif normal_velo_vec.y < 0.0:
			force_vec.y = 1 * vertBrakeForce * weightMultiplier;
	else:
		force_vec.y = vert_scaled * vertMoveForce * weightMultiplier;
				
	if rot_move == 0.0:
		torque_force.y = -normal_torque_vec.y * rotateTorque;
	else:
		torque_force.y = rot_move * rotateTorque;
	
	last_force_vec = force_vec;
	crane_root.apply_central_force(force_vec);
	crane_root.apply_torque(torque_force);
	
func attach(cont: Node3D):
	attached_container = cont;
	pin_joint_3d.node_a = crane_root.get_path();
	pin_joint_3d.node_b = cont.rigid_body_3d.get_path();
	update_ropes();

func detach(_cont: Node3D):
	reset_joint();
	crane_root.angular_velocity = Vector3.ZERO;
	attached_container = null;
	update_ropes();
		
func set_attachable_container(cont: Node3D):
	attachable_container = cont;
	update_ropes();
	
func reset_joint():
	pin_joint_3d.node_a = NodePath("");
	pin_joint_3d.node_b = NodePath("");
	
func allow_input(allow: bool):
	input_enabled = allow;

func update_ropes():
	if attached_container != null:
		var anchors = attached_container.anchor_proxies;
		for i in range(min(ropes.size(), anchors.size())):
			ropes[i].set_ends(hook.rope_proxy_bottom, anchors[i]);
	elif attachable_container != null:
		var anchors = attachable_container.anchor_proxies;
		for i in range(min(ropes.size(), anchors.size())):
			ropes[i].set_ends(attachable_container.pickupable_anchor, anchors[i]);
	else:
		for rope in ropes:
			rope.set_ends(null, null);

func set_input_listener(listener_cb: Callable):
	input_listener = listener_cb;
		
	
