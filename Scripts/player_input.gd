extends Node

signal ball_moved(direction: Vector2, velocity: float)
signal is_dragging(direction: Vector2)
signal not_dragging()

var velocity: int = 0
var direction: Vector2
var dragging : bool = false
var mouse_pos: Vector3
var ball_pos : Vector3
const RAY_LENGHT = 1000
const MAX_VEL = 40
const BasePlaneMask: int = 1 << 31

@onready var camera = get_node("../Camera3D")
@onready var ball = get_node("../Ball")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ball.input_event.connect(_begin_move)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _begin_move(camera: Node, event: InputEvent, 
	event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		print_debug("Mouse clicked on this object!")
		dragging = true


func _physics_process(delta: float) -> void:
	if dragging:
		is_dragging.emit(direction.normalized())
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
			self.velocity = min(MAX_VEL, direction.length()*5)


func _input(event: InputEvent) -> void:
	if dragging: 
		if event is InputEventMouseButton:  
			if (not event.pressed):
				if mouse_pos:
					# If the ray hits something, get the collision point
					print_debug("Mouse 3D Position:", mouse_pos)
					print_debug("Ball position:", ball_pos)
					
					ball_moved.emit(self.direction, self.velocity)
				else:
					print("No collision detected")

			dragging = false
			not_dragging.emit()
