extends Node

@onready var runtime_menu_ui = $RuntimeMenuUI
@onready var pause_menu_node = $RuntimeMenuUI/Node/PauseMenuNode
@onready var btn_resume = $RuntimeMenuUI/Node/PauseMenuNode/RuntimeMenu/BtnResume

enum MenuType {NONE, PAUSE, SCORE};

# Called when the node enters the scene tree for the first time.
func _ready():
	btn_resume.pressed.connect(on_resume_pressed);
	set_pause(false);
	print("Owner is %s and root is %s" % [owner, get_tree().root]);
	if owner == null && OS.has_feature("editor"):
		# Show by default when running scene from editor
		set_pause(true);

func _input(event):
	if event.is_action_pressed("esc"):
		set_pause(!get_tree().paused);
			
func show_menu(menu_type: MenuType):
	hide_menu();
	var showing_menu: bool = false;
	match (menu_type):
		MenuType.PAUSE:
			pause_menu_node.show_menu();
			showing_menu = true;
	runtime_menu_ui.visible = showing_menu;
			
func hide_menu():
	pause_menu_node.hide_menu();
	runtime_menu_ui.visible = false;

func on_resume_pressed():
	set_pause(false);	

func set_pause(paused: bool):
	get_tree().paused = paused;
	show_menu(MenuType.PAUSE if paused else MenuType.NONE);
