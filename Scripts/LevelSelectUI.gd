extends BoxContainer

@onready var btn_back = $BtnBack
@onready var item_list = $ScrollContainer/ItemList

signal back_pressed;
signal level_selected(index: int);

# Called when the node enters the scene tree for the first time.
func _ready():
	btn_back.pressed.connect(func(): back_pressed.emit());
	item_list.item_activated.connect(on_item_activated);
	item_list.focus_exited.connect(on_focus_exited);
	item_list.focus_entered.connect(on_focus_entered);
	
func on_item_activated(index: int):
	print("selected %d, unloadnig %s" % [index, owner.name]);
	level_selected.emit(index);
	
func on_focus_exited():
	item_list.deselect_all();

func on_focus_entered():
	item_list.select(0);

func update_level_list(levels: PackedStringArray, scores: Dictionary):
	item_list.clear();
	for level in levels:
		var level_name: String = level.get_basename();
		var display_name: String = level_name;
		if display_name.contains("_"):
			display_name = level_name.split("_")[1];
		var score_text: String = "";
		if scores.has(level_name):
			var level_score = scores[level_name];
			score_text = " - %d/%d" % [level_score["score"], level_score["total"]];
		item_list.add_item(display_name + score_text);

