extends MeshInstance3D
var dir = Vector3.FORWARD
var is_dragging = false
@onready var player = self.get_parent()
@onready var ball = self.get_parent().get_node("Ball")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.transform.origin = ball.global_position
	self.player.is_dragging.connect(change_direction)
	self.player.not_dragging.connect(visibility_off)
	self.visible = false

	
func visibility_off():
	self.is_dragging = false


func change_direction(direction: Vector2, percentage:float):
	self.dir = Vector3(direction.x, 0, direction.y).normalized()*2.5
	self.set_scale(Vector3(1,1,percentage))
	self.is_dragging = true

	
func _physics_process(delta: float) -> void:
	self.global_position = ball.global_position
	if not dir == Vector3.ZERO and is_dragging:
		self.look_at(dir + global_position)
	self.visible = is_dragging
	
