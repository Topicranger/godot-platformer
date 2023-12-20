extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _state_chart: StateChart = $StateChart
@onready var _animation_tree: AnimationTree = $AnimationTree
@onready var _animation_state_machine: AnimationNodeStateMachinePlayback = _animation_tree.get("parameters/playback")
@onready var _mesh: MeshInstance3D = $MeshInstance3D
@onready var _camera: Camera3D = get_viewport().get_camera_3d()

func _physics_process(delta):

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("player_left", "player_right", "player_up", "player_down")
	var camera_dir = _camera.get_camera_transform().basis.get_euler()
	var direction = ((basis.rotated(Vector3.UP, camera_dir.y) * Vector3(input_dir.x, 0, input_dir.y))*1.2).limit_length()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		_mesh.look_at(to_global(direction))
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		_state_chart.send_event("airborne")
	else:
		_state_chart.send_event("grounded")
	
	# let the state machine know if we are moving or not
	if velocity.length_squared() <= 0.005:
		_state_chart.send_event("idle")
	else:
		_state_chart.send_event("moving")

## Called in states that allow jumping, we process jumps only in these.
func _on_jump_enabled_state_physics_processing(_delta):
	if Input.is_action_just_pressed("player_jump"):
		$Jump.play()
		velocity.y = JUMP_VELOCITY
		_state_chart.send_event("jump")

## Called when the jump transition is taken in the double-jump
## state. Only used to play the double jump animation.
func _on_double_jump_jump():
	$DoubleJump.play()
##	_animation_state_machine.travel("DoubleJump")
	#pass
