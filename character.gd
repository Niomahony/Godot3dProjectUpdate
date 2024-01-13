extends CharacterBody3D


var jumps = 2
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var momentum = 50
var jump_speed = 5
var mouse_sensitivity = 0.002
var jump_strafe = 1
var canwallrun = true
var usedwallrun = false
var fallspeed = 1
var slamming = false
func _physics_process(delta):
	velocity.y += -gravity * delta * fallspeed
	var input = Input.get_vector("backward", "forward", "left", "right")
	if is_on_floor() or jump_strafe != 0:
		
		var movement_dir = transform.basis * Vector3(input.x, 0, input.y)
		
		velocity.x = movement_dir.x  * momentum
		velocity.z = movement_dir.z  * momentum
	
	
	if is_on_floor() and momentum> 50 or is_on_wall() and momentum> 75: #slow down on floor/ speed up in air
		momentum = momentum * 0.95
	else:
		momentum += momentum*0.005
		
	if is_on_wall() or is_on_floor() or Input.is_action_just_pressed("jump"):
		slamming = false
		fallspeed = 1
	else:
		fallspeed = fallspeed * 1.01

	move_and_slide()
	#==========================
	#jump mechanics
	#==========================
	
	if  jumps > 0 and Input.is_action_just_pressed("jump"): #BIG if jump input is entered during strafe timer, second timer gets eaten
		jump_strafe = 1
		velocity.y = jump_speed
		jumps = jumps -1
		$wallrun_timer.wait_time = 1
		await get_tree().create_timer(0.5).timeout
		jump_strafe = 0
		
		
	elif is_on_floor() or is_on_wall() and canwallrun == true: #reset jumps on wallrun/floor
		jumps = 2
		jump_strafe = 1
		
	if Input.is_action_just_pressed("jump"):
		jump_strafe = 1
	
	#==========================
	#wall mechanics
	#==========================
		
	if is_on_wall() and canwallrun == true: #kicked off the wall after ~0.8s
		velocity.y = velocity.y * 0.8                      #hover on wall
		if $wallrun_timer.is_stopped():
			$wallrun_timer.wait_time = 1
			$wallrun_timer.start() 
		elif $wallrun_timer.get_time_left() <= 0.2:
			canwallrun = false
			velocity.y += 0
			usedwallrun = true
			
	#else:
		#$wallrun_timer.stop() #stops it from editing your y velocity if you arent on wall
		
		
	if is_on_wall() and momentum> 75: #slow down on wall
		momentum = momentum * 0.98
		
	if jump_strafe == 1 and usedwallrun == false: #resets wallrun timer if it hasnt ran out
		canwallrun = true
		
	if is_on_floor(): #reset wallrun on floor contact
		usedwallrun = false
		
	#==========================
	#ground slam >.<
	#==========================
	
	if Input.is_action_just_pressed("crouch") and not is_on_floor() or Input.is_action_just_pressed("crouch") and not is_on_wall():
		velocity.y += -gravity*2
		slamming = true
		
	if slamming == true:
		momentum = momentum*1.03
	
	#==========================
	#mouse mechanics/bindings
	#==========================
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
	
func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: #camera movement
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_z(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))		
#==============================================================================
#==============================================================================
	
	#testgit
