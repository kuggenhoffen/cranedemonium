extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var batch_proxy = $RigidBody3D/BatchProxy

signal lift_animation_finished;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func on_lift_animation_finish():
	lift_animation_finished.emit();

func play_lift_up():
	animation_player.play("lift_up");

func reset():
	animation_player.play("RESET");
