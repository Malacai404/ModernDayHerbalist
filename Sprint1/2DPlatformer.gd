extends CharacterBody2D

# ==========================
# Jump King Style Settings
# ==========================
const WALK_SPEED = 200.0
const GROUND_ACCEL = 1800.0
const GROUND_FRICTION = 1600.0

var coyote_time = 0.2
var score = 0

var was_on_floor = false

const AIR_CONTROL = 200.0          # Very low = limited air movement
const MAX_AIR_SPEED = 340.0

const MIN_JUMP_FORCE = 120.0
const MAX_JUMP_FORCE = 550.0
const JUMP_CHARGE_TIME = 0.55      # Time to reach full charge

const GRAVITY_MULTIPLIER = 1.4
const FALL_GRAVITY_MULTIPLIER = 2.1   # Stronger gravity when falling

var jump_charge = 0.0
var is_charging = false
@onready var rich_text_label = $"../RichTextLabel"
@onready var floor_check = $floorCheck

var last_touched_objects = [null, null, null, null, null]

func _physics_process(delta):
	rich_text_label.text = "Score: " + str(score)
	# --- Gravity ---
	if not is_on_floor():
		var gravity = get_gravity() * delta
		if velocity.y > 0:  # Falling
			velocity.y += gravity.y * FALL_GRAVITY_MULTIPLIER
		else:               # Rising
			velocity.y += gravity.y * GRAVITY_MULTIPLIER
	# --- Jump Charging ---
	if Input.is_action_just_pressed("jump") and is_on_floor():
		is_charging = true
		jump_charge = 0.0

	if is_charging:
		jump_charge += delta
		jump_charge = min(jump_charge, JUMP_CHARGE_TIME)
		
		# Optional: Visual squash while charging
		scale.y = lerp(1.0, 0.75, jump_charge / JUMP_CHARGE_TIME)

	if Input.is_action_just_released("jump") and is_charging:
		_jump()
	
	# --- Horizontal Movement ---
	var direction = Input.get_axis("left", "right")
	
	if is_on_floor():
		# Ground movement (good acceleration + friction)
		if direction:
			velocity.x = move_toward(velocity.x, direction * WALK_SPEED, GROUND_ACCEL * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, GROUND_FRICTION * delta)
	else:
		# Limited air control
		if direction:
			velocity.x = move_toward(velocity.x, direction * MAX_AIR_SPEED, AIR_CONTROL * delta)

	move_and_slide()
	
		# Landing detection
	if !was_on_floor and is_on_floor():
		if floor_check.get_overlapping_bodies() != null:
				if floor_check.get_overlapping_bodies()[0] != last_touched_objects[0] and floor_check.get_overlapping_bodies()[0] != last_touched_objects[1] and floor_check.get_overlapping_bodies()[0] != last_touched_objects[2] and floor_check.get_overlapping_bodies()[0] != last_touched_objects[3]:
					score+=1
				last_touched_objects.insert(0, floor_check.get_overlapping_bodies()[0])

	# Save floor state for next frame
	was_on_floor = is_on_floor()
	
# ======================
# Jump Function
# ======================
func _jump():
	var charge_ratio = jump_charge / JUMP_CHARGE_TIME
	var jump_power = lerp(MIN_JUMP_FORCE, MAX_JUMP_FORCE, charge_ratio)
	
	velocity.y = -jump_power
	is_charging = false
	jump_charge = 0.0
	
	# Reset scale after jump
	scale.y = 1.0

	# Optional: Add a little forward boost when jumping at full charge
	# if charge_ratio > 0.9:
	#     velocity.x *= 1.08
