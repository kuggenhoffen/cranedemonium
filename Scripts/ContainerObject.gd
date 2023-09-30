extends Node3D

@onready var rigid_body_3d = $RigidBody3D
@onready var decal = $RigidBody3D/Decal

var id_texture: ImageTexture;
var identifier: String;

var crane: Node3D;

@export
var anchor_proxies: Array[Node3D];

signal entered_attach_area(container);
signal exited_attach_area(container);

# Called when the node enters the scene tree for the first time.
func _ready():
	if id_texture != null:
		decal.texture_albedo = id_texture;
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	if crane != null && false:
		print("Crane pos %s" % crane.global_position);
		for node in anchor_proxies:
			var offset_vec: Vector3 = crane.global_position - node.global_position;
			print("distance %s" % (offset_vec.length_squared()));
			if offset_vec.length_squared() > 50.0:
				rigid_body_3d.apply_force(offset_vec * 2.5, node.global_position);
			else:
				print("idle");
			rigid_body_3d.apply_force(Vector3.UP * -2.5)
				
func set_data(tex: ImageTexture, id: String):
	id_texture = tex;
	identifier = id;

func _on_area_attach_body_entered(body: PhysicsBody3D):
	entered_attach_area.emit(self);

func _on_area_attach_body_exited(body: PhysicsBody3D):
	exited_attach_area.emit(self);

func attach(target: Node3D):
	pass

func detach(target: Node3D):
	pass
