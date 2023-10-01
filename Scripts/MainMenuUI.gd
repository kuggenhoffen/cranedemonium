extends Control

@onready var btn_start = $BoxContainer/BtnStart


# Called when the node enters the scene tree for the first time.
func _ready():
	btn_start.grab_focus();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
