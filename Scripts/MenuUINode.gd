class_name MenuUINode
extends Node

@export
var focus_control: Control;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func show_menu():
	for child in get_children():
		child.visible = true;
	if focus_control != null:
		focus_control.grab_focus.call_deferred();	

func hide_menu():
	for child in get_children():
		child.visible = false;
