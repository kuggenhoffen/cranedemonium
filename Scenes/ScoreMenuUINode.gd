extends MenuUINode

@onready var label = $Label
@onready var result_label = $ResultLabel
@onready var btn_next_level = $RuntimeMenu/BtnNextLevel
@onready var btn_back_to_main_menu = $RuntimeMenu/BtnBackToMainMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_data(level_time: int, total: int, correct: int, has_next_level: bool, timeout: bool):
	label.text = "You ran out of time" if timeout else "Level finished";
	result_label.text = "Handled correctly %d out of %d cargo." % [correct, total];
	if !timeout:
		result_label.text += "\nTime: %s" % level_time;
	btn_next_level.visible = has_next_level;
	if !has_next_level:
		btn_back_to_main_menu.grab_focus.call_deferred();
