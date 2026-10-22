extends CharacterBody2D

# ⭐ CLASSIC SONIC PHYSICS VALUES
const TOP_SPEED = 360.0
const ACCEL = 28.0
const DECEL = 300.0
const JUMP_VELOCITY = -400.0
const GRAVITY_FORCE = 1200.0

const RUN_DELAY = 1.1
const SECRET_TIME = 3.0
const IDLE_DELAY = 8.0

@onready var body_anim: AnimatedSprite2D = $body
@onready var tails_anim: AnimatedSprite2D = $tails
@onready var jump_sound: AudioStreamPlayer = $jump_sound
@onready var win_sound: AudioStreamPlayer = $"../win"
@onready var doll_sound: AudioStreamPlayer = $"../tails_doll" # optional

var hud
var score := 0
var lives := 3
var rings := 0

var walk_time := 0.0
var idle_timer := 0.0
var original_tails_x := 0.0
var secret_timer := 0.0
var in_secret := false
var is_jumping := false
var halt_timer := 0.0

var level_complete := false

# ⭐ Idle death system
var idle_death_timer := 0.0
var idle_death_limit := 180.0 # 3 minutes
var tails_doll_active := false

func _ready():
	original_tails_x = tails_anim.position.x
	hud = get_tree().get_first_node_in_group("hud")

	if hud:
		hud.set_lives(lives)
		hud.add_score(0)
		hud.set_rings(rings)

func add_score(amount: int):
	score += amount
	if hud:
		hud.add_score(amount)

func lose_life():
	lives -= 1
	if hud:
		hud.set_lives(lives)

func set_rings(amount: int):
	rings = amount
	if hud:
		hud.set_rings(rings)

# ⭐ PLAYER TOUCHES GOAL — WIN ANIMATION + WIN JINGLE
func reach_goal():
	if level_complete or tails_doll_active:
		return

	level_complete = true

	velocity = Vector2.ZERO
	tails_anim.visible = false

	if hud:
		hud.reset_time()

	body_anim.play("win")
	win_sound.play()

	await win_sound.finished

	get_tree().change_scene_to_file("res://areas/title.tscn")

# ⭐ TAILS DOLL EVENT (Idle for 3 minutes)
func trigger_tails_doll():
	tails_doll_active = true
	level_complete = true

	velocity = Vector2.ZERO
	tails_anim.visible = false

	# Play Tails Doll drop animation
	body_anim.play("tails_doll_drop")

	# Optional spooky sound
	if doll_sound:
		doll_sound.play()
		await doll_sound.finished
	else:
		await get_tree().create_timer(2.0).timeout

	# ⭐ Wait for the drop animation to finish
	await body_anim.animation_finished

	# ⭐ Hide the player (Sonic CD style)
	visible = false

	# Remove all lives
	lives = 0
	if hud:
		hud.set_lives(lives)

	# Switch to game over scene
	get_tree().change_scene_to_file("res://areas/game_over.tscn")

func _physics_process(delta: float) -> void:

	# ⭐ If level is complete or Tails Doll active, freeze movement
	if level_complete or tails_doll_active:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# ⭐ Idle death timer
	if velocity.x == 0 and velocity.y == 0:
		idle_death_timer += delta
	else:
		idle_death_timer = 0.0

	if idle_death_timer >= idle_death_limit:
		trigger_tails_doll()
		return

	# ⭐ PAUSE SUPPORT
	if get_tree().paused:
		body_anim.stop()
		tails_anim.stop()
		return

	# ⭐ SECRET MODE
	if in_secret:
		secret_timer -= delta
		if secret_timer <= 0:
			in_secret = false
		else:
			return

	# ⭐ HALT TIMER
	if halt_timer > 0:
		halt_timer -= delta
		move_and_slide()
		return

	# ⭐ GRAVITY
	if not is_on_floor():
		velocity.y += GRAVITY_FORCE * delta
	else:
		if is_jumping:
			is_jumping = false

	# ⭐ JUMP
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		idle_timer = 0.0
		body_anim.play("jump")
		tails_anim.visible = true
		tails_anim.play("wag")
		jump_sound.play()

	if is_jumping:
		move_and_slide()
		return

	# ⭐ MOVEMENT
	var direction := Input.get_axis("left", "right")

	if direction != 0 and sign(direction) != sign(velocity.x) and abs(velocity.x) > TOP_SPEED * 0.5:
		velocity.x = 0
		walk_time = 0
		body_anim.play("halt")
		tails_anim.visible = true
		tails_anim.play("wag")
		halt_timer = 0.25
		move_and_slide()
		return

	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * TOP_SPEED, ACCEL)
		idle_timer = 0.0

		if direction < 0:
			body_anim.flip_h = true
			tails_anim.flip_h = true
			tails_anim.position.x = abs(original_tails_x)
		else:
			body_anim.flip_h = false
			tails_anim.flip_h = false
			tails_anim.position.x = -abs(original_tails_x)

		walk_time += delta

		if walk_time < RUN_DELAY:
			body_anim.play("walk")
			tails_anim.visible = true
			tails_anim.play("wag")
		else:
			body_anim.play("run")
			tails_anim.visible = false

	else:
		walk_time = 0.0
		velocity.x = move_toward(velocity.x, 0, DECEL)
		idle_timer += delta
		body_anim.play("idle")
		tails_anim.visible = true
		tails_anim.play("wag")

	# Up / Down animations
	if Input.is_action_pressed("up"):
		idle_timer = 0.0
		body_anim.play("up")
		tails_anim.visible = true
		tails_anim.play("wag")

	elif Input.is_action_pressed("down"):
		idle_timer = 0.0
		body_anim.play("down")
		tails_anim.visible = true
		tails_anim.play("wag")

	# ⭐ SECRET ANIMATIONS
	if Input.is_action_just_pressed("secret1"):
		idle_timer = 0.0
		body_anim.play("secret1")
		tails_anim.visible = true
		tails_anim.play("wag")
		in_secret = true
		secret_timer = SECRET_TIME

	if Input.is_action_just_pressed("secret2"):
		idle_timer = 0.0
		body_anim.play("secret2")
		tails_anim.visible = true
		tails_anim.play("wag")
		in_secret = true
		secret_timer = SECRET_TIME

	move_and_slide()
