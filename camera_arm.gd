extends SpringArm3D

const SPEED = 3.5

var spring_target_length: float = spring_length

@export var pitch_length: Curve

func _ready():
	text()
	pitch_length.bake()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var input_dir = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	if input_dir:
		input_dir = input_dir.limit_length()
		rotate(Vector3.DOWN, input_dir.x*delta*SPEED)
		rotate_object_local(Vector3.LEFT, input_dir.y*delta*SPEED)
		rotation.x = clampf(rotation.x, -1.5, 1)
		spring_target_length = 7*pitch_length.sample((-rotation.x+PI/2)/PI)
	spring_length = lerpf(spring_length, spring_target_length, 0.1)
	text()

func text():
	$Label.text = "pitch: %f\npitch_deg: %f\npitch+pi: %f\nlength: %f" % [rotation.x, rotation_degrees.x, (-rotation.x+PI/2)/PI, spring_length]
