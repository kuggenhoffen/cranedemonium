extends Node

var ContainerPrefab: PackedScene = preload("res://Prefabs/container.tscn");

@onready var text_renderer = $TextRenderer

const idLength: int = 4;
const idChars: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";

var container_queue: Array[Node];

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

func request_id_and_texture(obj: Node):
	container_queue.append(obj);

func generate_id():
	var id: String = "";
	for i in range(idLength):
		id += idChars[randi() % idChars.length()];
	print("Generated id: %s" % id);
	return id

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var cont: Node = container_queue.pop_back()
	if cont != null:
		var id: String = generate_id();
		var tex: ImageTexture = await get_id_texture(id);
		cont.set_id_and_texture(id, tex);
		
		
func get_id_texture(id):
	var tex: ImageTexture = await text_renderer.capture(id);
	return tex;
	
func instantiate_container():
	var new_container = ContainerPrefab.instantiate()
	return new_container
