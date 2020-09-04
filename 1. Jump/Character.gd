tool
extends KinematicBody2D

var Gravity: Vector2 = Vector2(0, 300)
var gravityScale: float = 5
var gravityTransitionSpeed: float = 1 # tooltip
var moveSpeed: float = 200
var accellerationTime: float = 3
var jump_force: float = 400
var maxJumpCount: float = 1

var currentSpeed = 0
var currentGravityScale = 1
var targetGravityScale = 1
var currentJumpNumber = 0
var isGrounded = false
var Velocity = Vector2()

func _get(property):
	match(property):
		"gravity/direction":
			return Gravity # One can implement custom getter logic here
		"gravity/fall multiplier":
			return gravityScale # One can implement custom getter logic here
		"gravity/transition speed":
			return gravityTransitionSpeed # One can implement custom getter logic here
		"movement/speed":
			return moveSpeed # One can implement custom getter logic here
		"movement/accelleration time":
			return accellerationTime # One can implement custom getter logic here
		"jump/force":
			return jump_force # One can implement custom getter logic here
		"jump/count":
			return maxJumpCount # One can implement custom getter logic here

func _set(property, value):
	match(property):
		"gravity/direction":
			Gravity = value # One can implement custom setter logic here
			return true
		"gravity/fall multiplier":
			gravityScale = value # One can implement custom setter logic here
			return true
		"gravity/transition speed":
			gravityTransitionSpeed = value # One can implement custom getter logic here
			return true
		"movement/speed":
			moveSpeed = value # One can implement custom getter logic here
			return true
		"movement/accelleration time":
			accellerationTime = value # One can implement custom getter logic here
			return true
		"jump/force":
			jump_force = value # One can implement custom getter logic here
			return true
		"jump/count":
			maxJumpCount = value # One can implement custom getter logic here
			return true
	return false

func _get_property_list():
	return [
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT,
			"name": "gravity/direction",
			"type": TYPE_VECTOR2
		},
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT,
			"name": "gravity/fall multiplier",
			"type": TYPE_REAL
		},
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT,
			"name": "gravity/transition speed",
			"type": TYPE_REAL
		},
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT,
			"name": "movement/speed",
			"type": TYPE_REAL
		},
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT,
			"name": "movement/accelleration time",
			"type": TYPE_REAL
		},
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT,
			"name": "jump/force",
			"type": TYPE_REAL
		},
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT,
			"name": "jump/count",
			"type": TYPE_REAL
		},
	]

func _physics_process(delta):	
	if Input.is_action_pressed("moveLeft"):
		currentSpeed = lerp(currentSpeed, -moveSpeed, delta * accellerationTime)
	elif Input.is_action_pressed("moveRight"):
		currentSpeed = lerp(currentSpeed, moveSpeed, delta * accellerationTime)
	else:
		currentSpeed = lerp(currentSpeed, 0, delta * accellerationTime * 2)

	if Input.is_action_just_pressed("Jump"):
		if isGrounded || currentJumpNumber < maxJumpCount:
			var jumpScale = lerp(jump_force, jump_force * .1, currentJumpNumber / maxJumpCount)
			isGrounded = false;
			targetGravityScale = 1
			currentGravityScale = 1
			
			if Velocity.y > 0:
				Velocity.y = 0
			
			Velocity.y -= jumpScale
			currentJumpNumber += 1
		
	if Input.is_action_just_released("Jump") || Velocity.y > 0:
		targetGravityScale = gravityScale
	
	Velocity.x = currentSpeed

	currentGravityScale = lerp(currentGravityScale, targetGravityScale, delta * gravityTransitionSpeed)
	Velocity += Gravity * currentGravityScale * delta
	
	move_and_slide(Velocity)
	var slideCount = get_slide_count()
	for i in range(slideCount):
		var collision = get_slide_collision(i)
		Velocity = Velocity.project(collision.get_normal().rotated(PI/2))
		
	if Velocity.y <= 0:
		targetGravityScale = 1

func _on_Grounding_body_entered(body):
	isGrounded = true
	currentJumpNumber = 0

func _on_Grounding_body_exited(body):
	if isGrounded:
		currentJumpNumber = 1
		
	isGrounded = false
