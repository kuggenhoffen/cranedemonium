extends Node3D

@onready var label_3d = $Label3D

var time_left_cb: Callable;
var update_timer: Timer = Timer.new();

# Called when the node enters the scene tree for the first time.
func _ready():
	update_timer.timeout.connect(update);
	update_timer.autostart = true;
	add_child(update_timer);
	update_timer.start(0.5);
	if owner == null && OS.has_feature("editor"):
		# Show by default when running scene from editor
		var test_timer: = Timer.new();
		test_timer.autostart = true;
		add_child(test_timer);
		test_timer.start(70);
		set_time_left_callback(func(): return test_timer.time_left);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_time_left_callback(callback: Callable):
	time_left_cb = callback;
	
func update():
	var time_left: float = 0.0;
	if time_left_cb.is_valid():
		time_left = time_left_cb.call();
	update_label(time_left);	
	
func update_label(time_left: float):
	var minutes: int = time_left / 60;
	var seconds: int = time_left - minutes * 60;
	label_3d.text = "TIME LEFT\n%02d:%02d" % [minutes, seconds];
	
