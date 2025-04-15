extends Node

var is_recording := false
var frame_count := 0

const SAVE_FOLDER := "res://frames"

func _ready():
	# Make sure the directory exists
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("frames"):
		dir.make_dir("frames")

func _process(delta):
	if Input.is_action_just_pressed("start_frame"):
		is_recording = true
		frame_count = 0
		print("Recording started")

	elif Input.is_action_just_pressed("stop_frame"):
		is_recording = false
		print("Recording stopped")

	if is_recording:
		save_frame_as_image()

func save_frame_as_image():
	var viewport := get_viewport()
	var image := viewport.get_texture().get_image()
	image.flip_y()  # Flip the image vertically for correct orientation

	var file_path := "%s/frame_%05d.png" % [SAVE_FOLDER, frame_count]
	var error := image.save_png(file_path)
	if error != OK:
		print("❌ Failed to save frame %d: Error code %d" % [frame_count, error])
	else:
		print("✅ Saved: ", file_path)

	frame_count += 1
