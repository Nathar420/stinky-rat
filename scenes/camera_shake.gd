extends Camera2D

var shake_amount: float = 0.0
var shake_decay: float = 5.0
var noise = FastNoiseLite.new()
var noise_y = 0.0

func _ready() -> void:
	# Setup noise for smooth shake
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()
	noise.frequency = 2.0

func _process(delta: float) -> void:
	if shake_amount > 0:
		shake_amount = lerpf(shake_amount, 0.0, shake_decay * delta)
		
		# Use noise for smooth camera shake
		noise_y += delta * 10.0
		offset.x = noise.get_noise_2d(0, noise_y) * shake_amount
		offset.y = noise.get_noise_2d(100, noise_y) * shake_amount
	else:
		offset = Vector2.ZERO

func add_shake(amount: float) -> void:
	shake_amount += amount
	# Cap maximum shake
	shake_amount = min(shake_amount, 20.0)
