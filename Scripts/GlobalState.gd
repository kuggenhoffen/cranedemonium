extends Node

var main_menu: PackedScene = preload("res://Scenes/main_menu.tscn")
var main_scene: PackedScene = preload("res://Scenes/main.tscn");
const level_path: String = "res://Prefabs/LevelBatches/";

var levels: PackedStringArray;

var current_level: Node;
var current_level_index: int = -1;

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Load levels");
	levels = DirAccess.get_files_at(level_path);
	for level in levels:
		print("Loaded %s" % level);
	if OS.has_feature("editor"):
		# When running main scene from editor, load first level
		var root = get_tree().root;
		if root.has_node("main/GameManager"):
			var game_manager: Node = root.get_node("main/GameManager");
			if game_manager != null && current_level == null:
				current_level = game_manager.get_parent();
				game_manager.load_level_path.call_deferred(level_path + levels[0])
		
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_levels():
	return levels;

func unload_scene(node: Node):
	print("Unload scene %s" % node.name);
	node.queue_free();
	get_tree().root.remove_child(node);

func load_main_scene():
	current_level = main_scene.instantiate();
	get_tree().root.add_child(current_level);
	
func load_level(level_index: int):
	print("Loading level %d" % level_index);
	current_level_index = level_index;
	current_level.get_node("GameManager").load_level_path(level_path + levels[current_level_index]);

func load_main_scene_and_level(level_index: int):
	load_main_scene();
	load_level(level_index);

func unload_and_switch_to_level(node: Node, index: int):
	unload_scene(node);
	load_main_scene_and_level.call_deferred(index);
	
func load_main_menu():
	if current_level != null:
		unload_scene(current_level);
		current_level = null;
	var new_main_menu = main_menu.instantiate();
	get_tree().root.add_child(new_main_menu);

func reload_level():
	if current_level != null && current_level_index != -1:
		unload_and_switch_to_level(current_level, current_level_index);
	else:
		print("asd")
