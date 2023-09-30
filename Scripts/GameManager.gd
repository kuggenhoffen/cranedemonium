extends Node

var ContainerPrefab: PackedScene = preload("res://Prefabs/container.tscn");

@onready var text_renderer = $TextRenderer
@onready var crane = $Crane

const idLength: int = 4;
const idChars: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
var current_container: Node3D;
var attached_container: Node3D;

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("esc"):
		var id: String = generate_id();
		var tex: ImageTexture = await text_renderer.capture(id);
		var new_container = ContainerPrefab.instantiate()
		new_container.set_data(tex, id);
		new_container.entered_attach_area.connect(on_container_entered_attach_area);
		new_container.exited_attach_area.connect(on_container_exited_attach_area);
		add_child(new_container);
	
	if Input.is_action_just_pressed("primary"):
		if current_container != null && attached_container == null:
			attached_container = current_container;
			crane.attach(attached_container);
		elif attached_container != null:
			crane.detach(attached_container);
			attached_container = null;

func generate_id():
	var id: String = "";
	for i in range(idLength):
		id += idChars[randi() % idChars.length()];
	print("Generated id: %s" % id);
	return id
	
func on_container_entered_attach_area(container: Node3D):
	print("Entered area %s" % container.identifier);
	current_container = container;

func on_container_exited_attach_area(container: Node3D):
	print("Exited area %s" % container.identifier);
	current_container = null;
