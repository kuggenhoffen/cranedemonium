extends SubViewport

@onready var label = $Label


# Called when the node enters the scene tree for the first time.
func _ready():
	#size = label.get_rect().size
	#print("Size is %s, label size %s", size, label.size);
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func capture(text: String):
	label.text = text;
	render_target_update_mode = SubViewport.UPDATE_ONCE;
	await RenderingServer.frame_post_draw
	var tex: ImageTexture = ImageTexture.create_from_image(get_texture().get_image());
	render_target_update_mode = SubViewport.UPDATE_DISABLED;	
	return tex;

	
