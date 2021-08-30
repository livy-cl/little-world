extends Spatial

export(int) var chunk_size = 64
export(int) var chunks_amount = 16

export(int) var bumpyness = 6 # how many bumps there are in the terrain
export(int) var mountainous = 200  # How many mountains there are

var noise

var chunks = {}
var unready_chunks = {}
var thread


func add_chunk(x, z):
	var key = str(x) + "," + str(z)
	
	if chunks.has(key) or unready_chunks.has(key):
		return
	
	if not thread.is_active():
		thread.start(self, "load_chunk", [thread, x, z])
		unready_chunks[key] = 1


func load_chunk(arr):
	var thread = arr[0]
	var x = arr[1]
	var z = arr[2]
	
	var chunk = Chunk.new(noise, x * chunk_size, z * chunk_size, chunk_size)
	chunk.translation = Vector3(x * chunk_size, 0, z * chunk_size)
	
	call_deferred("load_done", chunk, thread)


func load_done(chunk, thread):
	add_child(chunk)
	var key = str(chunk.x / chunk_size) + "," + str(chunk.z / chunk_size)
	chunks[key] = chunk
	unready_chunks.erase(key)
	
	thread.wait_to_finish() 


func get_chunk(x, z):
	var key = str(x) + "," + str(z)
	
	if chunks.has(key):
		return chunks.get(key)
	
	return null


func update_chunks():
	var palyer_translation = $Player.translation
	var player_chunk_loc = Vector3(
		int(palyer_translation.x) / chunk_size, 
		0, 
		int(palyer_translation.z) / chunk_size
	)
	
	for x in range(player_chunk_loc.x - chunks_amount * 0.5, player_chunk_loc.x + chunks_amount + 0.5):
		for z in range(player_chunk_loc.z - chunks_amount * 0.5, player_chunk_loc.z + chunks_amount + 0.5):
			add_chunk(x, z)
			
			var chunk = get_chunk(x, z)
			if chunk != null:
				chunk.should_remove = false
	


func clean_up_chunks():
	for key in chunks:
		var chunk = chunks[key]
		
		if chunk.should_remove:
			chunk.queue_free()
			chunks.erase(key)


func reset_chunks():
	for key in chunks:
		chunks[key].should_remove = true


func _ready():
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = bumpyness
	noise.period = mountainous
	
	thread = Thread.new()


func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen


func _process(delta):
	update_chunks()
	clean_up_chunks()
	reset_chunks()
