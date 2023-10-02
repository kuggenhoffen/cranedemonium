extends Node

@onready var crane = $Crane
@onready var container_factory = $"../ContainerFactory"
@onready var camera_3d = $Camera3D
@onready var container_spawn = $ContainerSpawn
@onready var lift = $Arena/Lift
@onready var ticker_left = $Arena/TickerLeft
@onready var ticker_right = $Arena/TickerRight
@onready var goal_right = $Arena/GoalRight
@onready var goal_left = $Arena/GoalLeft
@onready var runtime_menu = $"../RuntimeMenu"
@onready var timer_screen = $Arena/TimerScreen
@onready var help_texts = $HelpTexts


signal level_finished(level_time, total_containers, correcct_containers);

const goal_update_time: float = 15.0;

enum Target {LEFT_HOLE, RIGHT_HOLE};
	
class ContainerListItem:
	enum State {NONE, IN_PLAY, SUCCESS, FAILURE};
	
	var container: Node3D;
	var initialized: bool;
	var state: State;
	var target: Target;
	
	func _init(cont: Node3D):
		container = cont;
		initialized = false;
		state = State.NONE;
		target = Target.LEFT_HOLE;

var current_container: Node3D;
var attached_container: Node3D;

var current_level_batch: Node3D;

var containers_list: Array[ContainerListItem];

var input_enabled: bool = false;
var timer = Timer.new();
var level_start_time: int;
var time_limit_timer = Timer.new();

# Called when the node enters the scene tree for the first time.
func _ready():
	time_limit_timer.timeout.connect(func(): check_level_finish(true));
	timer_screen.set_time_left_callback(func(): return time_limit_timer.time_left);
	add_child(time_limit_timer);
	camera_3d.set_target(crane.hook);
	lift.reset();
	#load_level(levels[0]);
	lift.lift_animation_finished.connect(on_lift_finished);
	goal_left.body_entered.connect(func(body): on_body_entered_goal(body, Target.LEFT_HOLE));
	goal_right.body_entered.connect(func(body): on_body_entered_goal(body, Target.RIGHT_HOLE));

func load_level_path(path: String):
	print("Load level from path %s" % path);
	var level_to_load: PackedScene = ResourceLoader.load(path);
	load_level(level_to_load);
	help_texts.on_level_loaded(path);
	if help_texts.need_input():
		crane.set_input_listener(help_texts.on_input_received);
	
func load_level(new_level: PackedScene):
	if current_level_batch != null:
		current_level_batch.queue_free();
	current_level_batch = new_level.instantiate()
	for child in current_level_batch.get_children():
		var cont = child as ContainerObject;
		if cont:
			prepare_container(cont);
	add_child(current_level_batch);
	current_level_batch.global_position = lift.batch_proxy.global_position;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):	
	if input_enabled && Input.is_action_just_pressed("primary"):
		if current_container != null && attached_container == null:
			help_texts.on_container_attached();
			attached_container = current_container;
			crane.attach(attached_container);
		elif attached_container != null:
			crane.detach(attached_container);
			attached_container = null;

func on_batch_initialized():
	print("All containers initialized");
	lift.play_lift_up();
	
func on_container_entered_attach_area(container: Node3D):
	print("Entered area %s" % container.identifier);
	current_container = container;
	crane.set_attachable_container(current_container)
	help_texts.on_attach_area_enter();

func on_container_exited_attach_area(container: Node3D):
	print("Exited area %s" % container.identifier);
	current_container = null;
	crane.set_attachable_container(current_container)

func on_container_initialized(container: Node3D):
	var some_uninitialized: bool = false;
	var item_initialized: bool = false;
	for item in containers_list:
		if item.container == container:
			item.initialized = true;
			item_initialized = true;
			# If we already encountered some uninitialized, we can early exit
			if some_uninitialized:
				break;
		elif !item.initialized:
			some_uninitialized = true;
			# Can early exit, since we already set the current container initialized
			if item_initialized:
				break;
	if item_initialized && !some_uninitialized:
		on_batch_initialized();
	
func on_body_entered_goal(node: Node3D, target: Target):
	if not node is ContainerRigidbody:
		return;
	var cont: ContainerObject = node.container as ContainerObject;
	if not cont:
		return;
	for cont_item in containers_list:
		if cont_item.container == cont:
			cont_item.state = ContainerListItem.State.SUCCESS if cont_item.target == target else ContainerListItem.State.FAILURE;
			if cont_item.state == ContainerListItem.State.SUCCESS:
				if time_limit_timer.time_left > 0 && !time_limit_timer.is_stopped():
					var new_time = time_limit_timer.time_left + 10;
					time_limit_timer.stop();
					time_limit_timer.start(new_time);
			ticker_left.set_id_status(cont_item.container.identifier, cont_item.state == ContainerListItem.State.SUCCESS);
			ticker_right.set_id_status(cont_item.container.identifier, cont_item.state == ContainerListItem.State.SUCCESS);
			cont.queue_free();
			cont_item.container = null;
			break;
	update_goals();

func prepare_container(cont: ContainerObject):
	containers_list.append(ContainerListItem.new(cont));
	cont.entered_attach_area.connect(on_container_entered_attach_area);
	cont.exited_attach_area.connect(on_container_exited_attach_area);
	cont.initialized.connect(on_container_initialized);

func create_container():
	var new_container = await container_factory.instantiate_container();
	add_child(new_container);
	new_container.position = container_spawn.position;

func on_lift_finished():
	start_level();
	
func start_level():
	level_start_time = Time.get_ticks_msec();
	input_enabled = true;
	crane.allow_input(true);
	timer.autostart = true;
	timer.wait_time = goal_update_time;
	add_child(timer);
	timer.timeout.connect(update_goals);
	update_goals();
	start_time_limit(current_level_batch);
	help_texts.on_level_started();
	

func update_goals():
	# Pick container and side, and post the id to ticker
	var idle_containers: Array[ContainerListItem] = containers_list.filter(func(item): return item.state == ContainerListItem.State.NONE);
	print("Containers in idle: %s" % idle_containers.size());
	if idle_containers.size() <= 0:
		check_level_finish(false);
		return;
	var next_goal: ContainerListItem = idle_containers.pick_random();
	next_goal.state = ContainerListItem.State.IN_PLAY;
	var which_goal: bool = help_texts.which_goal(randi() % 2 == 0);
	next_goal.target = Target.LEFT_HOLE if which_goal else Target.RIGHT_HOLE;
	if next_goal.target == Target.LEFT_HOLE:
		ticker_left.add_id(next_goal.container.identifier)
	else:
		ticker_right.add_id(next_goal.container.identifier)
		
func get_level_duration():
	return Time.get_ticks_msec() - level_start_time;
	
func check_level_finish(timeout: bool):
	var unfinished_containers: Array[ContainerListItem] = containers_list.filter(
		func(item): 
			return item.state == ContainerListItem.State.NONE || item.state == ContainerListItem.State.IN_PLAY;
	);
	if (unfinished_containers.size() == 0 || timeout) && !help_texts.need_defer_level_finish():
		level_finish(timeout);
	
func level_finish(timedout: bool):
	var level_duration: int = get_level_duration();	
	var correctly_handled: int = 0;
	var total_containers: int = containers_list.size();
	for cont in containers_list:
		if cont.state == ContainerListItem.State.SUCCESS:
			correctly_handled += 1;
	level_finished.emit(level_duration, total_containers, correctly_handled);
	runtime_menu.show_score_menu(level_duration, total_containers, correctly_handled, timedout);

func start_time_limit(batch):
	if batch.LevelTimeLimitSecs != 0:
		time_limit_timer.start(batch.LevelTimeLimitSecs)
		
