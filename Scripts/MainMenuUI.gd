extends Node


@onready var level_select_node = $LevelSelectNode
@onready var level_select = $LevelSelectNode/LevelSelect

@onready var main_menu_node = $MainMenuNode
@onready var btn_start = $MainMenuNode/MainMenu/BtnStart
@onready var btn_options = $MainMenuNode/MainMenu/BtnOptions
@onready var btn_quit = $MainMenuNode/MainMenu/BtnQuit

var global_state: Node;

# Called when the node enters the scene tree for the first time.
func _ready():
	global_state = get_node("/root/GlobalState");
	
	level_select.back_pressed.connect(on_level_select_back_pressed);
	level_select.level_selected.connect(on_level_selected);
	
	btn_start.pressed.connect(on_start_pressed);
	btn_options.pressed.connect(on_options_pressed);
	btn_quit.pressed.connect(on_quit_pressed);
	
	level_select.update_level_list(global_state.get_levels(), global_state.get_scores());
	
	show_main_menu();

func on_quit_pressed():
	get_tree().quit()

func on_start_pressed():
	show_level_select();
	
func on_options_pressed():
	pass

func on_level_select_back_pressed():
	show_main_menu();

func show_main_menu():
	level_select_node.hide_menu();
	main_menu_node.show_menu();
	get_tree().paused = false;

func show_level_select():
	main_menu_node.hide_menu();
	level_select_node.show_menu();

func on_level_selected(index: int):
	global_state.unload_and_switch_to_level(owner, index);

