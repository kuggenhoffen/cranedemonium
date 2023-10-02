class_name ContainerObject
extends Node3D

@onready var rigid_body_3d = $RigidBody3D
@onready var decal = $RigidBody3D/Decal

var id_texture: ImageTexture;
var identifier: String;

var crane: Node3D;
var container_factory: Node;

@onready var anchor_1 = $RigidBody3D/Anchor1
@onready var anchor_2 = $RigidBody3D/Anchor2
@onready var anchor_3 = $RigidBody3D/Anchor3
@onready var anchor_4 = $RigidBody3D/Anchor4

@onready var pickupable_anchor = $RigidBody3D/Anchor5


var anchor_proxies: Array[Node3D];

signal entered_attach_area(container);
signal exited_attach_area(container);
signal initialized(container);

# Called when the node enters the scene tree for the first time.
func _ready():
	container_factory = get_tree().root.get_node("main/ContainerFactory");
	if container_factory != null:
		container_factory.request_id_and_texture(self);
	rigid_body_3d.container = self;
	anchor_proxies = [anchor_1, anchor_2, anchor_3, anchor_4];
		
func set_id_and_texture(id: String, tex: ImageTexture):
	id_texture = tex;
	identifier = id;
	decal.texture_albedo = id_texture;
	initialized.emit(self);

func _physics_process(_delta):
	if crane != null && false:
		for node in anchor_proxies:
			var offset_vec: Vector3 = crane.global_position - node.global_position;
			if offset_vec.length_squared() > 50.0:
				rigid_body_3d.apply_force(offset_vec * 2.5, node.global_position);
			rigid_body_3d.apply_force(Vector3.UP * -2.5)
				
func _on_area_attach_body_entered(_body: PhysicsBody3D):
	entered_attach_area.emit(self);

func _on_area_attach_body_exited(_body: PhysicsBody3D):
	exited_attach_area.emit(self);

func attach(_target: Node3D):
	pass

func detach(_target: Node3D):
	pass

