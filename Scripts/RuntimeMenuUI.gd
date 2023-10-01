extends Node

@onready var btn_back_to_main_menu = $PauseMenuNode/RuntimeMenu/BtnBackToMainMenu
@onready var btn_restart = $PauseMenuNode/RuntimeMenu/BtnRestart
@onready var btn_resume = $PauseMenuNode/RuntimeMenu/BtnResume

@onready var pause_menu_node = $PauseMenuNode


var global_state: Node;

# Called when the node enters the scene tree for the first time.
func _ready():
	global_state = get_node("/root/GlobalState");
	
	btn_back_to_main_menu.pressed.connect(on_back_pressed);
	btn_restart.pressed.connect(on_restart_pressed);
	btn_resume.pressed.connect(on_resume_pressed);
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_back_pressed():
	global_state.load_main_menu();
	
func on_restart_pressed():
	
	global_state.reload_level();
	
func on_resume_pressed():
	get_tree().paused = false;
	print("Unpausing");
	
