# Renders and samples a noise texture, used to simulate the effects of population on city growth

extends Sprite2D

@onready var noise: FastNoiseLite = texture.noise
var xform_inv: Transform2D

func _ready():
	var xform = get_global_transform().translated(get_rect().position)
	xform_inv = xform.affine_inverse()

func sample(global_pos: Vector2) -> float:
	var local_pos = xform_inv * (global_pos)
	return (noise.get_noise_2d(local_pos.x, local_pos.y) + 1.0) * 0.5
