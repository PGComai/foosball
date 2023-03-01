extends Node3D

@export var damping_force_multiplier: float
@export var linear_damp_multiplier: float
@export var spin_force: float
@export var g_torque_multiplier: float
@export var push_sensitivity: float
@export var mouse_spin_sensitivity: float
@export_enum('scroll', 'mouse') var spin_mode: int

var spin_strength = 0.0
var tork_multiplier = 1
var pushpull = 0.0
var mousespin = 0
var tork1 = Vector3.ZERO

@onready var spinner1 = $spinners/team1/ax1/RigidBody3D
@onready var spinner1h = $spinners/team1/ax1/RigidBody3D/rod/highlight
@onready var spinner2 = $spinners/team1/ax2/RigidBody3D
@onready var spinner2h = $spinners/team1/ax2/RigidBody3D/rod/highlight
@onready var spinner3 = $spinners/team1/ax4/RigidBody3D
@onready var spinner3h = $spinners/team1/ax4/RigidBody3D/rod/highlight
@onready var spinner4 = $spinners/team1/ax6/RigidBody3D
@onready var spinner4h = $spinners/team1/ax6/RigidBody3D/rod/highlight

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event.is_action_pressed("click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion:
		pushpull += event.relative.y * push_sensitivity
		mousespin -= event.relative.x * mouse_spin_sensitivity
	
func _physics_process(delta):
	pushpull = lerp(pushpull, 0.0, 0.2)
	mousespin = lerp(mousespin, 0.0, 0.2)
	spin_strength = lerp(spin_strength, 0.0, 0.1)
	
	if spin_strength != 0.0:
		tork_multiplier = 1/(1+spin_strength)
	
	if spin_strength > 0.0:
		if Input.is_action_just_released("spin_up"):
			spin_strength += 1.0
		elif Input.is_action_just_released("spin_down"):
			spin_strength = 0.0
	elif spin_strength < 0:
		if Input.is_action_just_released("spin_up"):
			spin_strength = 0.0
		elif Input.is_action_just_released("spin_down"):
			spin_strength -= 1.0
	else:
		if Input.is_action_just_released("spin_up"):
			spin_strength += 1.0
		elif Input.is_action_just_released("spin_down"):
			spin_strength -= 1.0
	
	if spin_mode == 0:
		tork1 = (Vector3.BACK * spin_strength) * delta * spin_force
	elif spin_mode == 1:
		tork1 = (Vector3.BACK * mousespin) * delta * spin_force
	var pushforce = Vector3.BACK * pushpull * delta
	
	spinner1h.visible = false
	spinner2h.visible = false
	spinner3h.visible = false
	spinner4h.visible = false
	if Input.is_action_pressed("q"):
		spinner1h.visible = true
		spinner1.apply_torque_impulse(tork1)
		spinner1.apply_central_impulse(pushforce)
	if Input.is_action_pressed("w"):
		spinner2h.visible = true
		spinner2.apply_torque_impulse(tork1)
		spinner2.apply_central_impulse(pushforce)
	if Input.is_action_pressed("e"):
		spinner3h.visible = true
		spinner3.apply_torque_impulse(tork1)
		spinner3.apply_central_impulse(pushforce)
	if Input.is_action_pressed("r"):
		spinner4h.visible = true
		spinner4.apply_torque_impulse(tork1)
		spinner4.apply_central_impulse(pushforce)
	spin(delta)
	
	#print(spin_strength)

func spin(delta):
	var spinners = [spinner1, spinner2, spinner3, spinner4]
	for rod in spinners:
		var rz = rod.rotation.z
		var gtork = Vector3.FORWARD * sin(rz) * delta * g_torque_multiplier
		var rtork = Vector3.FORWARD * rod.angular_velocity.z * damping_force_multiplier * delta
		rod.apply_torque_impulse(gtork + rtork)
		# linear slowing
		var zdamp = rod.linear_velocity.z * Vector3.FORWARD * delta * linear_damp_multiplier
		rod.apply_central_impulse(zdamp)

