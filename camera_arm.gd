extends SpringArm3D

const SPEED = 3.5

var input_dir : Vector2 = Vector2.ZERO
var spring_target_length: float = spring_length

@export var pitch_length: Curve

func _ready():
	text()
	pitch_length.bake()
	add_excluded_object(get_tree().get_first_node_in_group("player"))
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	input_dir += Input.get_vector(&"camera_left", &"camera_right", &"camera_up", &"camera_down") * delta * SPEED
	if input_dir:
		#Input.get_vector already limits the vector to 1, so we can skip that
		rotation.y -= input_dir.x #update pitch
		rotation.x = clampf(rotation.x - input_dir.y, -1.5, 1) #update yaw (clamp: -85.94 - 57.29°)
		
		#-rotation.x + PI/2 (baked) to get positive radiants and divide them by PI
		#to get range 0-1 for the spring_target_length curve
		spring_target_length = 7*pitch_length.sample((-rotation.x+1.5708)/PI)
		
		input_dir = Vector2.ZERO #reset accumulated input
	spring_length = lerpf(spring_length, spring_target_length, 6*delta)
	text()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		#print("Velocity: ", event.screen_velocity)
		input_dir += event.screen_relative * 0.001 * SPEED
	if event.is_action_pressed("camera_switch"):
		var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_IDLE).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		tween.tween_property(self, "rotation:y", angle_difference(rotation.y, $"../MeshInstance3D".rotation.y), 0.25).as_relative()

func text():
	$Label.text = "pitch: %f\npitch_deg: %f\npitch+pi: %f\nlength: %f" % [rotation.x, rotation_degrees.x, (-rotation.x+PI/2)/PI, spring_length]
