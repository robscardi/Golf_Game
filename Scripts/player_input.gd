extends Node

signal ball_moved(direction: Vector2, velocity: float)
signal is_dragging(direction: Vector2, percentage: float)
signal not_dragging()

var velocity: int = 0
var direction: Vector2
var dragging : bool = false
var mouse_pos: Vector3
var ball_pos : Vector3

var current_point : int:
	set(new_value):
		assert(new_value >= 0)
		current_point = new_value
		point_label.text = String.num_uint64(current_point)
	get:
		return current_point

const RAY_LENGHT :int = 1000
const MAX_VEL    :float = 40.0
const BasePlaneMask: int = 1 << 31


@onready var camera = $Camera3D
@onready var ball = $Ball
@onready var arrow = $Arrow
@onready var point_label = $PointLabel
@onready var base_plane = $BasePlane
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ball.input_event.connect(_begin_move)
	current_point = 0
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _begin_move(camera: Node, event: InputEvent, 
	event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		dragging = true


func _physics_process(delta: float) -> void:
	base_plane.global_position = ball.global_position
	if dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_direction = camera.project_ray_normal(mouse_pos)
		var ray_end = ray_origin + ray_direction * RAY_LENGHT
		
		# Step 4: Perform the raycast
		var space_state = camera.get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, 
		BasePlaneMask)
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		
		if result :
			self.ball_pos = ball.global_transform.origin
			self.mouse_pos = result.position
			var diff = ball_pos - self.mouse_pos
			self.direction = Vector2(diff.x, diff.z)
			self.velocity = min(MAX_VEL, direction.length()*7.5)
			is_dragging.emit(direction.normalized(), self.velocity/MAX_VEL)

func _input(event: InputEvent) -> void:
	if dragging: 
		if event is InputEventMouseButton:  
			if (not event.pressed):
				if mouse_pos:
					ball_moved.emit(self.direction, self.velocity)
					current_point += 1

			dragging = false
			not_dragging.emit()
