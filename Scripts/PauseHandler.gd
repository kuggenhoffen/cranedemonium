extends Node

@onready var runtime_menu_ui = $RuntimeMenuUI
@onready var pause_menu_node = $RuntimeMenuUI/Node/PauseMenuNode
@onready var score_menu_node = $RuntimeMenuUI/Node/ScoreMenuNode



enum MenuType {NONE, PAUSE, SCORE};

var global_state: Node;

var showing_menu_type: MenuType;

# Called when the node enters the scene tree for the first time.
func _ready():
	global_state = get_node("/root/GlobalState");
	set_pause(false);
	print("Owner is %s and root is %s" % [owner, get_tree().root]);
	if owner == null && OS.has_feature("editor"):
		# Show by default when running scene from editor
		set_pause(true);

func _input(event):
	if event.is_action_pressed("esc"):
		if showing_menu_type != MenuType.SCORE:
			set_pause(!get_tree().paused);
		else:
			_on_btn_back_to_main_menu_pressed();
			
			
func show_menu(menu_type: MenuType):
	hide_menu();
	var showing_menu: bool = false;
	match (menu_type):
		MenuType.PAUSE:
			get_tree().paused = true;
			pause_menu_node.show_menu();
		MenuType.SCORE:
			get_tree().paused = true;
			score_menu_node.show_menu();
			showing_menu = true;
		MenuType.NONE:
			get_tree().paused = false;
	showing_menu_type = menu_type;
	runtime_menu_ui.visible = showing_menu_type != MenuType.NONE;
			
			
func hide_menu():
	pause_menu_node.hide_menu();
	score_menu_node.hide_menu();
	runtime_menu_ui.visible = false;
	

func set_pause(paused: bool):
	show_menu(MenuType.PAUSE if paused else MenuType.NONE);


func _on_btn_back_to_main_menu_pressed():
	global_state.load_main_menu();


func _on_btn_restart_pressed():
	global_state.reload_level();


func _on_btn_resume_pressed():
	set_pause(false);


func _on_btn_next_level_pressed():
	global_state.load_next_level();


func show_score_menu(level_time: int, total_containers: int, correctly_handled_containers: int, timeout: bool):
	show_menu(MenuType.SCORE);
	score_menu_node.set_data(level_time, total_containers, correctly_handled_containers, global_state.has_next_level(), timeout);
