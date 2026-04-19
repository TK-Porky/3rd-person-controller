extends PlayerState
class_name FiringState

var _ray: RayCast3D
var _fire_timer := 0.0

var _came_from_cover: bool

func enter() -> void:
	_ray = player.camera_controller.get_fire_raycast()
	_fire_timer = 0.0
	_came_from_cover = player.is_in_cover() 
	_execute_shot()

func update(delta: float) -> void:
	_fire_timer -= delta
	
	if not player.weapon_manager.current_weapon.is_automatic:
		var next := "Unarmed" if _came_from_cover else "Aiming"
		state_machine.transition_to(state_machine.get_node(next))
		return
	
	if Input.is_action_pressed("shoot") and _fire_timer <= 0.0:
		_execute_shot()
	elif not Input.is_action_pressed("shoot"):
		var next := "Unarmed" if _came_from_cover else "Aiming"
		state_machine.transition_to(state_machine.get_node(next))

func _execute_shot() -> void:
	var weapon := player.weapon_manager.current_weapon
	_fire_timer = weapon.fire_rate
	player.weapon_manager.consume_ammo()
	
	var aim_point := player.camera_controller.get_camera_aim_point()
	
	var weapon_ray := player.vfx_manager.get_weapon_raycast()
	var muzzle_pos := player.vfx_manager.get_weapon_muzzle_position()
	
	weapon_ray.global_position = muzzle_pos
	weapon_ray.target_position = weapon_ray.to_local(aim_point)
	weapon_ray.force_raycast_update()
	
	if weapon_ray.is_colliding():
		var hit_point := weapon_ray.get_collision_point()
		var hit_normal := weapon_ray.get_collision_normal()
		var hit_object := weapon_ray.get_collider()
		player.vfx_manager.spawn_impact(hit_point, hit_normal)
		if hit_object.has_method("take_damage"):
			hit_object.take_damage(weapon.damage)
	else:
		player.vfx_manager.spawn_impact(aim_point, Vector3.UP)
	
	if not player.weapon_manager.can_shoot():
		state_machine.transition_to(state_machine.get_node("Reloading"))
	
	player.vfx_manager.spawn_muzzle_flash()
