class_name BossDog
extends CharacterBody2D

## Top-down boss. Safe to run before the art exists: missing animations are skipped,
## and the shockwave, dirt mound, and a stand-in dog are drawn with code when no sprite is assigned.

# --- Health and contact ---

## Total health. The dog enrages (Zoomies) at the fraction set below.
@export var max_health: int = 1750
## Damage when the player walks into the dog.
@export var contact_damage: int = 24
## Damage while the dog is mid-charge. Higher than normal contact.
@export var charge_contact_damage: int = 42
## How far the charge flings the player.
@export var charge_knockback: float = 520.0
## Seconds before the same touch can hurt the player again.
@export var contact_cooldown: float = 0.5
## Score added to the player when the dog dies.
@export var score_reward: int = 14000
## Damage taken is multiplied by this during the skid after a charge. Above 1 means a punish window.
@export var skid_damage_taken_multiplier: float = 1.5

# --- Chase / circle ---

## Speed while closing in or orbiting.
@export var chase_speed: float = 115.0
## Distance the dog tries to keep while circling. Farther than this, it walks straight in.
@export var keep_distance: float = 190.0
## Orbit speed as a fraction of chase speed. 0.5 matches the cat.
@export var orbit_speed_ratio: float = 0.5
## Seconds of circling between special moves.
@export var decision_interval: float = 2.2

# --- Zoomies (under 30% health) ---

## Health fraction that starts Zoomies. 0.30 is 30%.
@export var enrage_health_ratio: float = 0.30
## Multiplier on chase speed and underground mound speed while enraged.
@export var enrage_speed_multiplier: float = 1.45
## Cooldowns finish sooner while enraged. 0.6 means they take 60% as long.
@export var enrage_cooldown_multiplier: float = 0.60
## Extra multiplier on charge speed while enraged. Kept small so the dash stays readable.
@export var enrage_charge_speed_multiplier: float = 1.15
## Playback speed of dog_animation while enraged.
@export var enrage_anim_speed_scale: float = 1.3
## Minimum charges in a row once Zoomies starts.
@export var charge_chain_min: int = 2
## Maximum charges in a row once Zoomies starts.
@export var charge_chain_max: int = 3

# --- Charge ---

## Straight-line dash speed.
@export var charge_speed: float = 620.0
## Crouch / paw-scrape time before the first dash. The aim locks at the end of this.
@export var charge_windup_time: float = 0.55
## Shorter crouch used for the 2nd and 3rd dashes in a Zoomies chain.
@export var charge_chain_windup_time: float = 0.32
## How long the dash travels.
@export var charge_duration: float = 0.45
## Recovery after each dash. The dog slides and takes extra damage.
@export var skid_duration: float = 0.48
## Speed at the start of the skid. It eases down to zero.
@export var skid_speed: float = 160.0
## Seconds before Charge can be picked again.
@export var charge_cooldown: float = 5.5

# --- Bark / shockwave ---

## Time the dog stands and barks before the ring starts growing.
@export var bark_windup_time: float = 0.45
## Extra time the dog holds still after the ring is done.
@export var bark_recover_time: float = 0.20
## Seconds before Bark can be picked again.
@export var bark_cooldown: float = 7.5
## How far the ring travels.
@export var shockwave_max_radius: float = 280.0
## How fast the ring grows, in pixels per second.
@export var shockwave_expand_speed: float = 340.0
## Thickness of the damaging edge. Only that band hurts, not the whole disc.
@export var shockwave_thickness: float = 36.0
## Radius of your shockwave picture at scale 1. A 128x128 ring that touches the edges is 64.
@export var shockwave_sprite_radius: float = 64.0
## Damage dealt by the bark ring.
@export var bark_damage: int = 20
## How far the bark flings the player.
@export var bark_knockback: float = 700.0
## How hard the bark flings nearby fleas outward.
@export var flea_bark_knockback: float = 520.0

# --- Dig ambush ---

## Time spent playing the dig-down before the dog vanishes.
@export var dig_down_time: float = 0.60
## How long the dirt mound chases the player.
@export var burrow_time: float = 2.5
## Last part of the burrow. The mound stops homing and the camera shakes.
@export var burrow_warning_time: float = 0.55
## How fast the mound slides toward the player.
@export var mound_speed: float = 140.0
## The mound stops nudging once it is this close to the player, before the warning lock.
@export var mound_stop_distance: float = 18.0
## Eruption hits the player if they are within this many pixels of the mound.
@export var emerge_radius: float = 78.0
## Damage dealt by the eruption.
@export var emerge_damage: int = 36
## How far the eruption flings the player.
@export var emerge_knockback: float = 480.0
## Time the dog holds the emerge pose before chasing again.
@export var emerge_recover_time: float = 0.55
## Seconds before Dig can be picked again.
@export var dig_cooldown: float = 9.0

# --- Flea shake ---

## Fleas flung out in one shake.
@export var fleas_per_spawn: int = 12
## Seconds between automatic shakes. Also the cooldown before Shake can be picked as a move.
@export var flea_spawn_cooldown: float = 11.0
## How far from the dog's center fleas appear.
@export var flea_spawn_radius: float = 54.0
## Launch speed handed to each flea. Their own script turns this into a short leap.
@export var flea_leap_speed: float = 2200.0
## How long the dog stands still in the shake.
@export var shake_duration: float = 0.80
## Seconds into the shake before the fleas actually launch.
@export var flea_release_delay: float = 0.25

# --- Loot ---

@export var xp_drops_count: int = 6
@export var gold_drops_count: int = 10
@export var health_drops_count: int = 4
## How long to wait on death if dog_death is missing or has no timing.
@export var death_fallback_time: float = 1.0

# --- Camera shake amounts (uses the player's Camera2D add_shake) ---

@export var charge_shake: float = 4.0
@export var bark_shake: float = 5.0
@export var warning_shake: float = 3.0
@export var emerge_shake: float = 8.0
@export var enrage_shake: float = 6.0

# --- Scenes ---
# The existing BossSpawner fills in the first six when it spawns this boss.
# Names match BossCat so that spawner can be pointed at the dog without a script change.
# loot_chest_scene and death_particles_scene are NOT copied by that spawner; set them here.

@export var enemy_flea_scene: PackedScene
@export var xp_drop_scene: PackedScene
@export var gold_pickup_scene: PackedScene
@export var health_pickup_scene: PackedScene
@export var floating_score_scene: PackedScene
@export var floating_damage_scene: PackedScene
@export var loot_chest_scene: PackedScene
## Played on the dog's death, and passed to each flea if the flea script has this property.
@export var death_particles_scene: PackedScene
## Optional ring art. If empty, and there is no Shockwave child, a circle is drawn.
@export var shockwave_scene: PackedScene
## Optional mound art. If empty, and there is no DirtMound child, a dirt blob is drawn.
@export var dirt_mound_scene: PackedScene
## Optional burst played where the dog erupts. If empty, a fading circle is drawn.
@export var eruption_scene: PackedScene

enum MoveState {
	CHASE,
	SHAKE,
	WINDUP,
	CHARGE,
	SKID,
	BARK,
	DIG,
	BURROW,
	EMERGE,
	DEAD,
}

enum Special {
	SHAKE,
	CHARGE,
	BARK,
	DIG,
}

const ANIM_WALK := &"dog_walk"
const ANIM_SHAKE := &"dog_shake"
const ANIM_WINDUP := &"dog_charge_windup"
const ANIM_CHARGE := &"dog_charge"
const ANIM_SKID := &"dog_skid"
const ANIM_BARK := &"dog_bark"
const ANIM_DIG := &"dog_dig"
const ANIM_EMERGE := &"dog_emerge"
const ANIM_DEATH := &"dog_death"

var current_health: int = 0
var player: Node2D = null
var state: MoveState = MoveState.CHASE
var is_dying: bool = false
var is_enraged: bool = false
var is_burrowed: bool = false

var state_time: float = 0.0
var decision_timer: float = 0.0
var damage_cooldown: float = 0.0
var last_damage_time: float = 0.0
var last_special: int = -1

var shake_cooldown_left: float = 0.0
var charge_cooldown_left: float = 0.0
var bark_cooldown_left: float = 0.0
var dig_cooldown_left: float = 0.0
var flea_spawn_timer: float = 0.0
var queued_shakes: int = 0
var shake_elapsed: float = 0.0
var fleas_released: bool = false
var warned_missing_fleas: bool = false

var flea_spawn_health_75: bool = false
var flea_spawn_health_50: bool = false
var flea_spawn_health_25: bool = false

var charge_direction: Vector2 = Vector2.RIGHT
var charges_remaining: int = 0
var charge_chains_total: int = 0
var facing_left: bool = false

var bark_released: bool = false
var shockwave_active: bool = false
var shockwave_radius: float = 0.0
var shockwave_origin: Vector2 = Vector2.ZERO
var shockwave_hit_player: bool = false
var shocked_fleas: Dictionary = {}
var shockwave_visual: Node2D = null
var shockwave_from_scene: bool = false
var shockwave_base_scale: Vector2 = Vector2.ONE
var draw_shockwave: bool = false

var mound_position: Vector2 = Vector2.ZERO
var mound_visual: Node2D = null
var mound_from_scene: bool = false
var mound_base_scale: Vector2 = Vector2.ONE
var draw_mound: bool = false
var warning_started: bool = false
var warning_shake_timer: float = 0.0

var eruption_visual: Node2D = null
var draw_erupt_flash: bool = false
var erupt_flash: float = 0.0
var flash_time: float = 0.0
var hit_flash_tween: Tween = null

var sprite_home: Vector2 = Vector2.ZERO
var aim_line: Line2D = null
var _last_effect_spawned: bool = false


func _ready() -> void:
	add_to_group("enemies")
	current_health = max_health
	flea_spawn_timer = flea_spawn_cooldown
	decision_timer = decision_interval
	var sprite := _sprite()
	if sprite:
		sprite_home = sprite.position
	_hide_named("Shockwave")
	_hide_named("DirtMound")
	_hide_named("Eruption")
	_play(ANIM_WALK)
	var area := get_node_or_null("Area2D") as Area2D
	if area and not area.body_entered.is_connected(_on_player_touched):
		area.body_entered.connect(_on_player_touched)


func _physics_process(delta: float) -> void:
	if is_dying:
		_tick_shockwave(delta)
		_tick_visuals(delta)
		return

	_acquire_player()
	damage_cooldown = maxf(0.0, damage_cooldown - delta)
	_tick_cooldowns(delta)

	if player == null:
		_tick_shockwave(delta)
		_tick_visuals(delta)
		return

	flea_spawn_timer -= delta * _cooldown_rate()
	if flea_spawn_timer <= 0.0:
		flea_spawn_timer = flea_spawn_cooldown
		_request_shake()

	match state:
		MoveState.CHASE:
			_process_chase(delta)
		MoveState.SHAKE:
			_process_shake(delta)
		MoveState.WINDUP:
			_process_windup(delta)
		MoveState.CHARGE:
			_process_charge(delta)
		MoveState.SKID:
			_process_skid(delta)
		MoveState.BARK:
			_process_bark(delta)
		MoveState.DIG:
			_process_dig(delta)
		MoveState.BURROW:
			_process_burrow(delta)
		MoveState.EMERGE:
			_process_emerge(delta)
		_:
			pass

	if is_dying:
		return

	if state != MoveState.BURROW:
		move_and_slide()
		if is_dying:
			return
		if state == MoveState.CHARGE:
			_poll_charge_contact()

	if is_dying:
		return

	_update_facing()
	_tick_shockwave(delta)
	_tick_visuals(delta)


func _process_chase(delta: float) -> void:
	_chase_movement()
	_play(ANIM_WALK)
	if queued_shakes > 0:
		queued_shakes -= 1
		_begin_shake()
		return
	decision_timer -= delta * _cooldown_rate()
	if decision_timer <= 0.0:
		_pick_special()


func _process_shake(delta: float) -> void:
	velocity = Vector2.ZERO
	shake_elapsed += delta
	if not fleas_released and shake_elapsed >= flea_release_delay:
		fleas_released = true
		_spawn_fleas()
	state_time -= delta
	if state_time <= 0.0:
		shake_cooldown_left = flea_spawn_cooldown
		flea_spawn_timer = flea_spawn_cooldown
		_enter_chase()


func _process_windup(delta: float) -> void:
	velocity = Vector2.ZERO
	state_time -= delta
	if state_time > 0.0:
		return
	charge_direction = Vector2.RIGHT
	if player and is_instance_valid(player):
		charge_direction = global_position.direction_to(player.global_position)
	if charge_direction.length_squared() < 0.0001:
		charge_direction = Vector2.RIGHT
	state = MoveState.CHARGE
	state_time = charge_duration
	velocity = charge_direction * charge_speed * _charge_speed_multiplier()
	_play(ANIM_CHARGE)
	_add_camera_shake(charge_shake * 0.5)


func _process_charge(delta: float) -> void:
	velocity = charge_direction * charge_speed * _charge_speed_multiplier()
	state_time -= delta
	if state_time <= 0.0:
		state = MoveState.SKID
		state_time = skid_duration
		_play(ANIM_SKID)


func _process_skid(delta: float) -> void:
	var blend := clampf(state_time / maxf(skid_duration, 0.01), 0.0, 1.0)
	velocity = charge_direction * skid_speed * blend
	state_time -= delta
	if state_time <= 0.0:
		_finish_charge_chain()


func _process_bark(delta: float) -> void:
	velocity = Vector2.ZERO
	state_time -= delta
	if not bark_released and state_time <= 0.0:
		_emit_shockwave()
		bark_released = true
		var travel := shockwave_max_radius / maxf(shockwave_expand_speed, 1.0)
		state_time = travel + bark_recover_time
	elif bark_released and state_time <= 0.0:
		_stop_shockwave()
		bark_cooldown_left = bark_cooldown
		_enter_chase()


func _process_dig(delta: float) -> void:
	velocity = Vector2.ZERO
	state_time -= delta
	if state_time <= 0.0:
		_enter_burrow()


func _process_burrow(delta: float) -> void:
	velocity = Vector2.ZERO
	var warning := state_time <= burrow_warning_time
	if not warning and player and is_instance_valid(player):
		var to_player := player.global_position - mound_position
		var distance := to_player.length()
		if distance > mound_stop_distance:
			mound_position += to_player / distance * mound_speed * _move_speed_multiplier() * delta
	if warning and not warning_started:
		warning_started = true
		warning_shake_timer = 0.0
		_add_camera_shake(warning_shake)
	if warning_started:
		warning_shake_timer -= delta
		if warning_shake_timer <= 0.0:
			warning_shake_timer = 0.18
			_add_camera_shake(warning_shake * 0.65)
		_pulse_mound()
	global_position = mound_position
	state_time -= delta
	if state_time <= 0.0:
		_erupt()


func _process_emerge(delta: float) -> void:
	velocity = Vector2.ZERO
	state_time -= delta
	if state_time <= 0.0:
		_hide_eruption_child()
		dig_cooldown_left = dig_cooldown
		_enter_chase()


func _chase_movement() -> void:
	if player == null or not is_instance_valid(player):
		velocity = Vector2.ZERO
		return
	var distance := global_position.distance_to(player.global_position)
	var direction := global_position.direction_to(player.global_position)
	var speed := chase_speed * _move_speed_multiplier()
	if distance > keep_distance:
		velocity = direction * speed
	else:
		var perpendicular := Vector2(-direction.y, direction.x)
		velocity = perpendicular * speed * orbit_speed_ratio


func _pick_special() -> void:
	var ready: Array[int] = []
	for special in [Special.SHAKE, Special.CHARGE, Special.BARK, Special.DIG]:
		if _special_ready(special):
			ready.append(special)
	if ready.is_empty():
		decision_timer = 0.35
		return
	var choice: int = ready[randi() % ready.size()]
	last_special = choice
	match choice:
		Special.SHAKE:
			_begin_shake()
		Special.CHARGE:
			_begin_charge()
		Special.BARK:
			_begin_bark()
		Special.DIG:
			_begin_dig()


func _special_ready(special: int) -> bool:
	if special == last_special:
		return false
	match special:
		Special.SHAKE:
			return shake_cooldown_left <= 0.0
		Special.CHARGE:
			return charge_cooldown_left <= 0.0
		Special.BARK:
			return bark_cooldown_left <= 0.0
		Special.DIG:
			return dig_cooldown_left <= 0.0
	return false


func _enter_chase() -> void:
	if is_dying:
		return
	state = MoveState.CHASE
	decision_timer = decision_interval
	velocity = Vector2.ZERO
	_play(ANIM_WALK)


func _begin_shake() -> void:
	if is_dying:
		return
	state = MoveState.SHAKE
	last_special = Special.SHAKE
	state_time = maxf(shake_duration, 0.05)
	shake_elapsed = 0.0
	fleas_released = false
	velocity = Vector2.ZERO
	_play(ANIM_SHAKE)
	print("Boss Dog shakes off fleas!")
	if flea_release_delay <= 0.0:
		fleas_released = true
		_spawn_fleas()


func _begin_charge() -> void:
	if is_dying:
		return
	if is_enraged:
		var low := maxi(1, mini(charge_chain_min, charge_chain_max))
		var high := maxi(low, maxi(charge_chain_min, charge_chain_max))
		charges_remaining = randi_range(low, high)
	else:
		charges_remaining = 1
	charge_chains_total = charges_remaining
	print("Boss Dog charges! Dashes: ", charge_chains_total)
	_enter_windup()


func _enter_windup() -> void:
	state = MoveState.WINDUP
	var chained := charges_remaining < charge_chains_total
	state_time = charge_chain_windup_time if chained else charge_windup_time
	if state_time < 0.05:
		state_time = 0.05
	velocity = Vector2.ZERO
	_play(ANIM_WINDUP)
	if chained:
		print("Boss Dog scrapes and charges again.")


func _finish_charge_chain() -> void:
	charges_remaining -= 1
	if charges_remaining > 0 and not is_dying:
		_enter_windup()
		return
	charge_cooldown_left = charge_cooldown
	_enter_chase()


func _begin_bark() -> void:
	if is_dying:
		return
	state = MoveState.BARK
	bark_released = false
	state_time = maxf(bark_windup_time, 0.05)
	velocity = Vector2.ZERO
	_play(ANIM_BARK)
	print("Boss Dog barks!")


func _begin_dig() -> void:
	if is_dying:
		return
	state = MoveState.DIG
	state_time = maxf(dig_down_time, 0.05)
	velocity = Vector2.ZERO
	_play(ANIM_DIG)
	print("Boss Dog digs!")


func _enter_burrow() -> void:
	state = MoveState.BURROW
	state_time = maxf(burrow_time, burrow_warning_time + 0.1)
	is_burrowed = true
	warning_started = false
	warning_shake_timer = 0.0
	mound_position = global_position
	velocity = Vector2.ZERO
	_set_sprite_visible(false)
	_set_hitbox_enabled(false)
	_show_mound()


func _erupt() -> void:
	global_position = mound_position
	is_burrowed = false
	warning_started = false
	_hide_mound()
	_set_sprite_visible(true)
	_set_hitbox_enabled(true)
	_play(ANIM_EMERGE)
	_spawn_eruption()
	_add_camera_shake(emerge_shake)
	_hurt_player_if_near(mound_position, emerge_radius, emerge_damage, emerge_knockback)
	state = MoveState.EMERGE
	state_time = maxf(emerge_recover_time, 0.05)
	velocity = Vector2.ZERO
	print("Boss Dog erupts!")


func _request_shake() -> void:
	if is_dying:
		return
	if state == MoveState.SHAKE:
		_spawn_fleas()
		return
	if queued_shakes < 3:
		queued_shakes += 1


func _spawn_fleas() -> void:
	if enemy_flea_scene == null:
		if not warned_missing_fleas:
			warned_missing_fleas = true
			push_warning("BossDog: enemy_flea_scene is empty, so no fleas were spawned.")
		return
	var parent := get_parent()
	if parent == null or fleas_per_spawn <= 0:
		return
	print("Boss Dog launches ", fleas_per_spawn, " fleas!")
	for i in fleas_per_spawn:
		var spawned := enemy_flea_scene.instantiate()
		if spawned == null:
			continue
		if not spawned is Node2D:
			spawned.queue_free()
			push_warning("BossDog: enemy_flea_scene root must be a Node2D.")
			return
		var flea := spawned as Node2D
		_give_flea_scenes(flea)
		var angle := TAU * float(i) / float(fleas_per_spawn)
		var away := Vector2.from_angle(angle)
		parent.add_child(flea)
		flea.global_position = global_position + away * flea_spawn_radius
		if "knockback_velocity" in flea:
			flea.set("knockback_velocity", away * flea_leap_speed)


func _give_flea_scenes(flea: Node) -> void:
	# The cat forgets loot_chest_scene and death_particles_scene. Pass every drop we know about.
	_set_if_present(flea, &"xp_drop_scene", xp_drop_scene)
	_set_if_present(flea, &"health_drop_scene", health_pickup_scene)
	_set_if_present(flea, &"gold_drop_scene", gold_pickup_scene)
	_set_if_present(flea, &"floating_score_scene", floating_score_scene)
	_set_if_present(flea, &"floating_damage_scene", floating_damage_scene)
	_set_if_present(flea, &"loot_chest_scene", loot_chest_scene)
	_set_if_present(flea, &"death_particles_scene", death_particles_scene)


func _set_if_present(node: Node, property: StringName, value: Variant) -> void:
	if property in node:
		node.set(property, value)


func _emit_shockwave() -> void:
	shockwave_active = true
	shockwave_radius = 0.0
	shockwave_origin = global_position
	shockwave_hit_player = false
	shocked_fleas.clear()
	_stop_shockwave_visual()
	shockwave_visual = _spawn_or_show(shockwave_scene, "Shockwave")
	shockwave_from_scene = _last_effect_spawned
	draw_shockwave = shockwave_visual == null
	if shockwave_visual:
		shockwave_base_scale = shockwave_visual.scale
		shockwave_visual.z_index = 2
	_add_camera_shake(bark_shake)
	queue_redraw()


func _tick_shockwave(delta: float) -> void:
	if not shockwave_active:
		return
	var previous := shockwave_radius
	shockwave_radius = minf(shockwave_max_radius, shockwave_radius + shockwave_expand_speed * delta)
	_shockwave_hits(previous, shockwave_radius)
	if shockwave_visual and is_instance_valid(shockwave_visual):
		var reference := shockwave_sprite_radius if shockwave_sprite_radius > 1.0 else 64.0
		var scale_factor := shockwave_radius / reference
		shockwave_visual.scale = shockwave_base_scale * scale_factor
	if shockwave_radius >= shockwave_max_radius - 0.5:
		_stop_shockwave()
	else:
		queue_redraw()


func _shockwave_hits(previous_radius: float, radius: float) -> void:
	if player and is_instance_valid(player) and not shockwave_hit_player:
		var player_distance := shockwave_origin.distance_to(player.global_position)
		if _in_ring_band(player_distance, previous_radius, radius):
			shockwave_hit_player = true
			_hurt_player(player, bark_damage, shockwave_origin, bark_knockback, false)
	for node in get_tree().get_nodes_in_group("enemies"):
		if node == self or not is_instance_valid(node) or not _is_flea(node):
			continue
		var flea_id := node.get_instance_id()
		if shocked_fleas.has(flea_id):
			continue
		if not node is Node2D:
			continue
		var flea := node as Node2D
		var flea_distance := shockwave_origin.distance_to(flea.global_position)
		if not _in_ring_band(flea_distance, previous_radius, radius):
			continue
		shocked_fleas[flea_id] = true
		if "knockback_velocity" in flea:
			var away := flea.global_position - shockwave_origin
			if away.length_squared() < 1.0:
				away = Vector2.RIGHT
			flea.set("knockback_velocity", away.normalized() * flea_bark_knockback)


func _in_ring_band(distance: float, previous_radius: float, radius: float) -> bool:
	var inner := previous_radius - shockwave_thickness
	return distance <= radius and distance >= inner


func _stop_shockwave() -> void:
	shockwave_active = false
	draw_shockwave = false
	_stop_shockwave_visual()
	queue_redraw()


func _stop_shockwave_visual() -> void:
	if shockwave_visual and is_instance_valid(shockwave_visual):
		shockwave_visual.scale = shockwave_base_scale
		if shockwave_from_scene:
			shockwave_visual.queue_free()
		else:
			shockwave_visual.visible = false
	shockwave_visual = null
	shockwave_from_scene = false


func _show_mound() -> void:
	draw_mound = false
	mound_visual = _spawn_or_show(dirt_mound_scene, "DirtMound")
	mound_from_scene = _last_effect_spawned
	if mound_visual:
		mound_base_scale = mound_visual.scale
		mound_visual.z_index = -1
	else:
		draw_mound = true
	queue_redraw()


func _pulse_mound() -> void:
	if mound_visual == null or not is_instance_valid(mound_visual):
		return
	var wobble := 1.0 + sin(Time.get_ticks_msec() / 1000.0 * 18.0) * 0.12
	mound_visual.scale = mound_base_scale * wobble


func _hide_mound() -> void:
	draw_mound = false
	warning_started = false
	if mound_visual and is_instance_valid(mound_visual):
		mound_visual.scale = mound_base_scale
		if mound_from_scene:
			mound_visual.queue_free()
		else:
			mound_visual.visible = false
	mound_visual = null
	mound_from_scene = false
	queue_redraw()


func _spawn_eruption() -> void:
	draw_erupt_flash = false
	erupt_flash = 0.0
	_hide_eruption_child()
	if eruption_scene != null and _spawn_world_oneshot(eruption_scene, global_position, 1.2):
		return
	var existing := get_node_or_null("Eruption") as Node2D
	if existing:
		existing.visible = true
		existing.position = Vector2.ZERO
		_play_effect(existing)
		eruption_visual = existing
		return
	draw_erupt_flash = true
	erupt_flash = 1.0
	queue_redraw()


func _hide_eruption_child() -> void:
	if eruption_visual and is_instance_valid(eruption_visual):
		eruption_visual.visible = false
	eruption_visual = null


func _spawn_or_show(packed: PackedScene, child_name: String) -> Node2D:
	_last_effect_spawned = false
	if packed != null:
		var inst := packed.instantiate()
		if inst is Node2D:
			var node := inst as Node2D
			add_child(node)
			node.visible = true
			node.position = Vector2.ZERO
			_play_effect(node)
			_last_effect_spawned = true
			return node
		if inst:
			inst.queue_free()
		push_warning("BossDog: effect scene root must be a Node2D. Using a child node or a drawn shape instead.")
	var existing := get_node_or_null(child_name) as Node2D
	if existing:
		existing.visible = true
		_play_effect(existing)
		return existing
	return null


func _spawn_world_oneshot(packed: PackedScene, at: Vector2, life: float) -> bool:
	if packed == null:
		return false
	var inst := packed.instantiate()
	if not inst is Node2D:
		if inst:
			inst.queue_free()
		push_warning("BossDog: effect scene root must be a Node2D. Skipping it.")
		return false
	var node := inst as Node2D
	var parent := get_parent()
	if parent == null:
		node.queue_free()
		return false
	parent.add_child(node)
	node.global_position = at
	_play_effect(node)
	var tree := get_tree()
	if tree == null:
		return true
	var timer := tree.create_timer(maxf(life, 0.1))
	timer.timeout.connect(func() -> void:
		if is_instance_valid(node):
			node.queue_free()
	)
	return true


func _play_effect(node: Node) -> void:
	if node is AnimatedSprite2D:
		var anim_sprite := node as AnimatedSprite2D
		var frames := anim_sprite.sprite_frames
		if frames == null:
			return
		var names := frames.get_animation_names()
		if names.is_empty():
			return
		var chosen := anim_sprite.animation
		if not frames.has_animation(chosen):
			chosen = names[0]
		anim_sprite.play(chosen)
		return
	if node is GPUParticles2D:
		(node as GPUParticles2D).emitting = true
	elif node is CPUParticles2D:
		(node as CPUParticles2D).emitting = true
	elif node.has_method("play"):
		node.call("play")


func _on_player_touched(body: Node2D) -> void:
	if is_dying or is_burrowed:
		return
	if not body.is_in_group("player"):
		return
	var amount := charge_contact_damage if state == MoveState.CHARGE else contact_damage
	var knockback := charge_knockback if state == MoveState.CHARGE else 0.0
	_hurt_player(body, amount, global_position, knockback, true)


func _poll_charge_contact() -> void:
	var area := get_node_or_null("Area2D") as Area2D
	if area == null:
		return
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			_on_player_touched(body)
			return


func _hurt_player(body: Node, amount: int, from: Vector2, knockback_strength: float, use_cooldown: bool) -> void:
	if body == null or not is_instance_valid(body) or not body.has_method("take_damage"):
		return
	if use_cooldown and damage_cooldown > 0.0:
		return
	if "is_invulnerable" in body and bool(body.get("is_invulnerable")):
		return
	if knockback_strength > 0.0:
		body.call("take_damage", amount, from)
	else:
		body.call("take_damage", amount)
	if use_cooldown:
		damage_cooldown = contact_cooldown
	if knockback_strength > 0.0 and "knockback_velocity" in body and body is Node2D:
		var target := body as Node2D
		var away := target.global_position - from
		if away.length_squared() < 1.0:
			away = charge_direction if charge_direction.length_squared() > 0.01 else Vector2.RIGHT
		target.set("knockback_velocity", away.normalized() * knockback_strength)
	if state == MoveState.CHARGE and use_cooldown:
		_add_camera_shake(charge_shake)


func _hurt_player_if_near(origin: Vector2, radius: float, amount: int, knockback_strength: float) -> void:
	_acquire_player()
	if player == null or not is_instance_valid(player):
		return
	if origin.distance_to(player.global_position) > radius:
		return
	_hurt_player(player, amount, origin, knockback_strength, false)


func take_damage(amount: int, is_crit: bool = false) -> void:
	if is_dying or is_burrowed:
		return
	var now := Time.get_ticks_msec() / 1000.0
	if now - last_damage_time < 0.05:
		return
	last_damage_time = now

	var dealt := amount
	if state == MoveState.SKID:
		dealt = maxi(1, int(round(float(amount) * skid_damage_taken_multiplier)))
	current_health -= dealt
	_spawn_damage_number(dealt, is_crit)
	if current_health <= 0:
		_die()
		return
	_flash_hit()
	_update_enrage()
	_check_health_fleas()


func _update_enrage() -> void:
	if is_enraged or max_health <= 0:
		return
	if float(current_health) / float(max_health) > enrage_health_ratio:
		return
	is_enraged = true
	var sprite := _sprite()
	if sprite:
		sprite.speed_scale = enrage_anim_speed_scale
	_add_camera_shake(enrage_shake)
	print("Boss Dog enraged: zoomies!")


func _check_health_fleas() -> void:
	if max_health <= 0:
		return
	var ratio := float(current_health) / float(max_health)
	if ratio <= 0.75 and not flea_spawn_health_75:
		flea_spawn_health_75 = true
		_request_shake()
	if ratio <= 0.50 and not flea_spawn_health_50:
		flea_spawn_health_50 = true
		_request_shake()
	if ratio <= 0.25 and not flea_spawn_health_25:
		flea_spawn_health_25 = true
		_request_shake()


func _die() -> void:
	if is_dying:
		return
	is_dying = true
	state = MoveState.DEAD
	velocity = Vector2.ZERO
	is_burrowed = false
	_stop_shockwave()
	_hide_mound()
	_hide_eruption_child()
	if aim_line:
		aim_line.visible = false
	_set_sprite_visible(true)
	_set_hitbox_enabled(false)
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	if hit_flash_tween and hit_flash_tween.is_valid():
		hit_flash_tween.kill()
	var sprite := _sprite()
	if sprite:
		sprite.modulate = Color.WHITE
		sprite.speed_scale = 1.0

	_award_score()
	_spawn_loot()
	_spawn_death_particles()
	print("Boss Dog defeated.")

	await _wait_for_death_animation()
	if is_instance_valid(self):
		queue_free()


func _wait_for_death_animation() -> void:
	# Timer only. Never await animation_finished: a missing or looping clip would stall the corpse.
	var wait := maxf(death_fallback_time, 0.05)
	if _has_anim(ANIM_DEATH):
		var sprite := _sprite()
		var length := _animation_length(sprite.sprite_frames, ANIM_DEATH)
		_play(ANIM_DEATH)
		if length > 0.0:
			wait = length
	var tree := get_tree()
	if tree == null:
		return
	await tree.create_timer(wait).timeout


func _award_score() -> void:
	var player_ref := get_tree().get_first_node_in_group("player") as Player
	if player_ref and player_ref.stats:
		player_ref.stats.add_score(score_reward)
		player_ref.stats.increment_kills()
	if floating_score_scene == null:
		return
	var parent := get_parent()
	if parent == null:
		return
	var floating := floating_score_scene.instantiate()
	if floating == null:
		return
	parent.add_child(floating)
	if floating is Node2D:
		(floating as Node2D).global_position = global_position
	if floating.has_method("set_score"):
		floating.call("set_score", score_reward)


func _spawn_loot() -> void:
	_scatter(xp_drop_scene, xp_drops_count)
	_scatter(gold_pickup_scene, gold_drops_count)
	_scatter(health_pickup_scene, health_drops_count)
	print("Boss Dog dropped loot!")


func _scatter(packed: PackedScene, count: int) -> void:
	if packed == null or count <= 0:
		return
	var parent := get_parent()
	if parent == null:
		return
	for _i in count:
		var drop := packed.instantiate()
		if drop == null:
			continue
		parent.add_child(drop)
		if drop is Node2D:
			var offset := Vector2(randf_range(-80.0, 80.0), randf_range(-80.0, 80.0))
			(drop as Node2D).global_position = global_position + offset


func _spawn_death_particles() -> void:
	_spawn_world_oneshot(death_particles_scene, global_position, 2.0)


func _spawn_damage_number(amount: int, is_crit: bool) -> void:
	if floating_damage_scene == null:
		return
	var parent := get_parent()
	if parent == null:
		return
	var number := floating_damage_scene.instantiate()
	if number == null:
		return
	# Set the number before add_child so FloatingDamage._ready sees a crit.
	if number.has_method("set_damage"):
		number.call("set_damage", amount, is_crit)
	parent.add_child(number)
	if number is Node2D:
		var offset := Vector2(randf_range(-30.0, 30.0), -40.0)
		(number as Node2D).global_position = global_position + offset


func _flash_hit() -> void:
	flash_time = 0.12
	var sprite := _sprite()
	if sprite == null:
		queue_redraw()
		return
	if hit_flash_tween and hit_flash_tween.is_valid():
		hit_flash_tween.kill()
	sprite.modulate = Color(1.0, 0.3, 0.3)
	hit_flash_tween = create_tween()
	hit_flash_tween.tween_interval(0.1)
	hit_flash_tween.tween_property(sprite, "modulate", Color.WHITE, 0.05)
	queue_redraw()


func _sprite() -> AnimatedSprite2D:
	return get_node_or_null("dog_animation") as AnimatedSprite2D


func _play(anim_name: StringName) -> void:
	var sprite := _sprite()
	if sprite == null:
		return
	var frames := sprite.sprite_frames
	if frames == null or not frames.has_animation(anim_name):
		return
	if frames.get_frame_count(anim_name) <= 0:
		return
	if sprite.animation == anim_name and sprite.is_playing():
		return
	sprite.play(anim_name)


func _has_anim(anim_name: StringName) -> bool:
	var sprite := _sprite()
	if sprite == null or sprite.sprite_frames == null:
		return false
	return sprite.sprite_frames.has_animation(anim_name) and sprite.sprite_frames.get_frame_count(anim_name) > 0


func _animation_length(frames: SpriteFrames, anim_name: StringName) -> float:
	var speed := frames.get_animation_speed(anim_name)
	if speed <= 0.0:
		return 0.0
	var total := 0.0
	var count := frames.get_frame_count(anim_name)
	for i in count:
		total += frames.get_frame_duration(anim_name, i)
	if total <= 0.0:
		return 0.0
	return total / speed


func _update_facing() -> void:
	if is_burrowed:
		return
	var dir := _facing_direction()
	if dir < -0.1:
		facing_left = true
	elif dir > 0.1:
		facing_left = false
	var sprite := _sprite()
	if sprite:
		sprite.flip_h = facing_left


func _facing_direction() -> float:
	if state == MoveState.CHARGE or state == MoveState.SKID:
		return charge_direction.x
	if state == MoveState.WINDUP or state == MoveState.BARK or state == MoveState.DIG or state == MoveState.EMERGE:
		if player and is_instance_valid(player):
			return player.global_position.x - global_position.x
	return velocity.x


func _set_sprite_visible(show_sprite: bool) -> void:
	var sprite := _sprite()
	if sprite == null:
		return
	sprite.visible = show_sprite
	if show_sprite:
		sprite.position = sprite_home
		var color := sprite.modulate
		color.a = 1.0
		sprite.modulate = color


func _set_hitbox_enabled(enabled: bool) -> void:
	var body_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if body_shape:
		body_shape.set_deferred("disabled", not enabled)
	var area := get_node_or_null("Area2D") as Area2D
	if area == null:
		return
	area.set_deferred("monitoring", enabled)
	var area_shape := area.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if area_shape:
		area_shape.set_deferred("disabled", not enabled)


func _hide_named(node_name: String) -> void:
	var node := get_node_or_null(node_name) as CanvasItem
	if node:
		node.visible = false


func _is_flea(node: Node) -> bool:
	if node is EnemyFlea:
		return true
	return node.get_node_or_null("flea_animation") != null


func _acquire_player() -> void:
	if player != null and is_instance_valid(player):
		return
	player = get_tree().get_first_node_in_group("player") as Node2D


func _tick_cooldowns(delta: float) -> void:
	var step := delta * _cooldown_rate()
	shake_cooldown_left = maxf(0.0, shake_cooldown_left - step)
	charge_cooldown_left = maxf(0.0, charge_cooldown_left - step)
	bark_cooldown_left = maxf(0.0, bark_cooldown_left - step)
	dig_cooldown_left = maxf(0.0, dig_cooldown_left - step)


func _cooldown_rate() -> float:
	if is_enraged and enrage_cooldown_multiplier > 0.01:
		return 1.0 / enrage_cooldown_multiplier
	return 1.0


func _move_speed_multiplier() -> float:
	return enrage_speed_multiplier if is_enraged else 1.0


func _charge_speed_multiplier() -> float:
	return enrage_charge_speed_multiplier if is_enraged else 1.0


func _add_camera_shake(amount: float) -> void:
	if amount <= 0.0:
		return
	var camera := get_viewport().get_camera_2d()
	if camera and camera.has_method("add_shake"):
		camera.call("add_shake", amount)


func _tick_visuals(delta: float) -> void:
	if erupt_flash > 0.0:
		erupt_flash = maxf(0.0, erupt_flash - delta / 0.40)
	if flash_time > 0.0:
		flash_time = maxf(0.0, flash_time - delta)
	_tick_aim_line()
	if draw_shockwave or draw_mound or erupt_flash > 0.0 or flash_time > 0.0 or _needs_placeholder():
		queue_redraw()


func _needs_placeholder() -> bool:
	return not is_burrowed and not _has_visible_art()


func _tick_aim_line() -> void:
	# Drawn as its own node so the line sits on top of dog_animation. Only used until dog_charge_windup exists.
	var show := state == MoveState.WINDUP and not _has_anim(ANIM_WINDUP) and player != null and is_instance_valid(player) and not is_dying
	if not show:
		if aim_line:
			aim_line.visible = false
		return
	if aim_line == null:
		aim_line = Line2D.new()
		aim_line.name = "ChargeAimLine"
		aim_line.width = 3.0
		aim_line.default_color = Color(1.0, 0.35, 0.25, 0.85)
		aim_line.z_index = 5
		aim_line.z_as_relative = true
		add_child(aim_line)
	var aim := (player.global_position - global_position).limit_length(150.0)
	aim_line.points = PackedVector2Array([Vector2.ZERO, aim])
	aim_line.visible = true


func _has_visible_art() -> bool:
	var sprite := _sprite()
	if sprite == null or not sprite.visible or sprite.sprite_frames == null:
		return false
	var anim_name := sprite.animation
	if not sprite.sprite_frames.has_animation(anim_name):
		return false
	return sprite.sprite_frames.get_frame_count(anim_name) > 0


func _draw() -> void:
	if _needs_placeholder():
		_draw_placeholder_dog()
	if draw_shockwave:
		var ring_radius := maxf(shockwave_radius, 1.0)
		draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 72, Color(1.0, 0.94, 0.72, 0.85), 4.0)
		if ring_radius > 8.0:
			draw_arc(Vector2.ZERO, ring_radius - 6.0, 0.0, TAU, 72, Color(1.0, 0.82, 0.35, 0.40), 2.0)
	if draw_mound:
		var wobble := 1.0
		if warning_started:
			wobble = 1.0 + sin(Time.get_ticks_msec() / 80.0) * 0.12
		draw_circle(Vector2(0, 8), 34.0 * wobble, Color(0.40, 0.26, 0.13, 0.95))
		draw_circle(Vector2(0, 0), 22.0 * wobble, Color(0.55, 0.36, 0.18, 0.95))
	if draw_erupt_flash and erupt_flash > 0.0:
		var burst := maxf(emerge_radius, 130.0) * (1.05 - 0.25 * erupt_flash)
		draw_circle(Vector2.ZERO, burst, Color(0.62, 0.40, 0.18, 0.40 * erupt_flash))
		draw_arc(Vector2.ZERO, burst, 0.0, TAU, 48, Color(0.85, 0.65, 0.30, 0.7 * erupt_flash), 4.0)


func _draw_placeholder_dog() -> void:
	var face := -1.0 if facing_left else 1.0
	var body := Color(0.55, 0.36, 0.20, 1.0)
	var ear := Color(0.42, 0.26, 0.14, 1.0)
	if flash_time > 0.0:
		body = Color(1.0, 0.35, 0.30, 1.0)
		ear = Color(0.85, 0.25, 0.20, 1.0)
	draw_circle(Vector2(0, 10), 28.0, body)
	draw_circle(Vector2(10.0 * face, -6.0), 16.0, body)
	draw_circle(Vector2(-10.0 * face, -18.0), 7.0, ear)
	draw_circle(Vector2(6.0 * face, -20.0), 7.0, ear)
	draw_circle(Vector2(20.0 * face, -4.0), 4.5, Color(0.25, 0.12, 0.08, 1.0))
