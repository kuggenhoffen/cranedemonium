extends Node3D

@onready var label_3d = $Label3D

const success_symbol: String = "✓";
const failure_symbol: String = "✗";
const max_items_shown: int = 5;
const status_show_duration: float = 5.0;
const status_check_timer_time: float = 0.2;

class TickerItem:
	enum Status {STATUS_WAITING, STATUS_SUCCESS, STATUS_FAILURE};
	var id_text: String;
	var status: Status = Status.STATUS_WAITING;
	var wait_time_left: float;
	var added_time: float;
		
	func _init(id: String, added_at: float):
		id_text = id;
		status = Status.STATUS_WAITING;
		wait_time_left = 0.0;
		added_time = added_at;
	
	func get_text():
		var text: String = id_text;
		if status == Status.STATUS_SUCCESS:
			text += success_symbol;
		elif status == Status.STATUS_FAILURE:
			text += failure_symbol;
		return text;

var items: Array[TickerItem];
var timer = Timer.new();

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.autostart = true;
	timer.wait_time = status_check_timer_time;
	add_child(timer);
	timer.timeout.connect(check_statuses);
	update_label();
	
func check_statuses():
	var update: bool = false;
	for idx in range(0, items.size()):
		var i = items.size() - idx - 1;
		if items[i].status != TickerItem.Status.STATUS_WAITING:
			items[i].wait_time_left -= timer.wait_time;
			print("Time left %s" % items[i].wait_time_left);
			if items[i].wait_time_left < 0.0:
				items.remove_at(i);
				update = true;
	if update:
		update_label()	

func add_id(id: String):
	items.append(TickerItem.new(id, Time.get_ticks_msec()));
	update_label();

func set_id_status(id: String, success: bool):
	for item in items:
		if item.id_text == id:
			item.status = TickerItem.Status.STATUS_SUCCESS if success else TickerItem.Status.STATUS_FAILURE;
			item.wait_time_left = status_show_duration + (timer.wait_time - timer.time_left);
			break;
	update_label();

func custom_sort(a: TickerItem, b: TickerItem):
	if a.status != TickerItem.Status.STATUS_WAITING && b.status == TickerItem.Status.STATUS_WAITING:
		return true;
	elif b.status != TickerItem.Status.STATUS_WAITING && a.status == TickerItem.Status.STATUS_WAITING:
		return false;
	return a.added_time < b.added_time;
	
func update_label():
	var new_text: String = "";
	
	# Sort so that finished goals are first
	items.sort_custom(custom_sort)
	
	var count: int = items.size();
	var show_count: int = count;
	if count > max_items_shown:
		show_count = max_items_shown - 1;
	var leftover_count: int = count - show_count;
	for i in range(show_count):
		new_text += items[i].get_text() + "\n";
	if leftover_count > 0:
		new_text += " +%s" % leftover_count;
	label_3d.text = new_text;
