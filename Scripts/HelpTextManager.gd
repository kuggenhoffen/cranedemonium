extends Node


@onready var help_text_1 = $HelpText1
@onready var help_text_3 = $HelpText3
@onready var help_text_7 = $HelpText7
@onready var help_text_2 = $HelpText2
@onready var help_text_4 = $HelpText4
@onready var help_text_5 = $HelpText5
@onready var help_text_6 = $HelpText6
@onready var help_text_8 = $HelpText8

var helpTexts = [help_text_1, help_text_2, help_text_3, help_text_4, help_text_5, help_text_6, help_text_7, help_text_8];

const default_timeout: = 10;

enum State {
	IGNORE, 
	STARTED, 
	WAIT_MOVE, 
	WAIT_UPDOWN_ROTATE, 
	WAIT_GO_TO_CONTAINER, 
	WAIT_PICKUP_CONTAINER, 
	SHOW_TICKER_SCREEN, 
	WAIT_GOAL, 
	LAST
};

var state: State = State.IGNORE;
var next_state: State = State.IGNORE;

var timer: Timer;
var advance_timer: Timer;

var move_input_received: bool = false;
var vert_input_received: bool = false;
var rot_input_received: bool = false;
var already_picked_up: bool = false;
var already_show_container: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new();
	timer.timeout.connect(on_timeout);
	advance_timer = Timer.new();
	advance_timer.one_shot = true;
	advance_timer.timeout.connect(func(): state_machine_advance(next_state));
	add_child(timer);
	add_child(advance_timer);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func state_machine_advance_deferred(to: State):
	if next_state != to:
		print("Set timeout from %s to %s" % [state, to]);
		next_state = to;
		advance_timer.stop();
		advance_timer.start(3);	

func state_machine_advance(to: State):
	print("Advance state machine from %s to %s" % [state, to]);
	exit_state(state);
	enter_state(to);
	
	
func enter_state(new_state: State):
	var timeout = default_timeout;
	match new_state:
		State.STARTED:
			timer.start(3);
		State.WAIT_MOVE:
			timer.start(default_timeout);
			help_text_1.visible = true;
		State.WAIT_UPDOWN_ROTATE:
			timer.start(default_timeout);
			help_text_2.visible = true;
		State.WAIT_GO_TO_CONTAINER:
			timeout = 5 if already_show_container else 30;
			timer.start(timeout);
			help_text_3.visible = true;
		State.WAIT_PICKUP_CONTAINER:
			timeout = 5 if already_picked_up else 30;
			timer.start(timeout);
			help_text_4.visible = true;
		State.SHOW_TICKER_SCREEN:
			timer.start(default_timeout);
			help_text_5.visible = true;
			help_text_6.visible = true;
		State.WAIT_GOAL:
			timer.start(default_timeout);
			help_text_7.visible = true;
			help_text_8.visible = true;
		
	state = new_state
		
		
func exit_state(old_state: State):
	match old_state:
		State.STARTED:
			timer.stop();
		State.WAIT_MOVE:
			timer.stop();
			help_text_1.visible = false;
		State.WAIT_UPDOWN_ROTATE:
			timer.stop();
			help_text_2.visible = false;
		State.WAIT_GO_TO_CONTAINER:
			timer.stop();
			help_text_3.visible = false;
		State.WAIT_PICKUP_CONTAINER:
			timer.stop();
			help_text_4.visible = false;
		State.SHOW_TICKER_SCREEN:
			timer.stop();
			help_text_5.visible = false;
			help_text_6.visible = false;
		State.WAIT_GOAL:
			timer.stop();
	
			
func on_timeout():
	state_machine_advance(state + 1);

func on_level_loaded(path: String):
	if path.contains("Tutorial") && state == State.IGNORE:
		state_machine_advance(state + 1);
	
func on_container_attached():
	already_picked_up = true;
	if state == State.WAIT_PICKUP_CONTAINER:
		state_machine_advance_deferred(state + 1);
	
func on_attach_area_enter():
	already_show_container = true;
	if state == State.WAIT_GO_TO_CONTAINER:
		state_machine_advance_deferred(state + 1);
	
func on_level_started():
	pass
	
func which_goal(left_goal_wanted: bool):
	if state != State.IGNORE:
		return false;
	return left_goal_wanted;

func need_defer_level_finish():
	return state != State.LAST && state != State.IGNORE;
	
func on_input_received(move_vec: Vector2, vert_move: float, rot_move: float):
	if move_vec != Vector2.ZERO:
		move_input_received = true;
	if vert_move != 0.0:
		vert_input_received = true;
	if rot_move != 0.0:
		rot_input_received = true;
	if move_input_received && state == State.WAIT_MOVE:
		state_machine_advance_deferred(state + 1);
	elif move_input_received && vert_input_received && rot_input_received && state == State.WAIT_UPDOWN_ROTATE:
		state_machine_advance_deferred(state + 1);
		
func need_input():
	return state != State.IGNORE;
