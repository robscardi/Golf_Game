extends RigidBody3D

@onready var player = get_node("/root/Test_Node/PlayerInput")

var input_dir: Vector3 = Vector3(0,0,0)
var input_vel: float = 0
var input_rec: bool = false

func _ready():
	transform.origin = Vector3(0,0.5,0)
	player.ball_moved.connect(apply_input)
	
func apply_input(direction: Vector2, velocity: float) -> void:
	input_dir = Vector3(direction.x, 0, direction.y).normalized()
	input_vel = velocity
	self.apply_impulse(input_dir*input_vel)
