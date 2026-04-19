extends PlayerState
class_name FiringState

var _ray: RayCast3D
var _fire_timer := 0.0

func enter() -> void:
	_ray = player.camera_controller.get_fire_raycast()
	_fire_timer = 0.0
	_execute_shot()

func update(delta: float) -> void:
	_fire_timer -= delta
	
	if not player.weapon_manager.current_weapon.is_automatic:
		state_machine.transition_to(state_machine.get_node("Aiming"))
		return
	
	if Input.is_action_pressed("shoot") and _fire_timer <= 0.0:
		_execute_shot()
	elif not Input.is_action_pressed("shoot"):
		state_machine.transition_to(state_machine.get_node("Aiming"))

func _execute_shot() -> void:
	var weapon := player.weapon_manager.current_weapon
	_fire_timer = weapon.fire_rate
	
	player.camera_controller.update_fire_raycast()
	if _ray.is_colliding():
		var hit_point := _ray.get_collision_point()
		var hit_normal := _ray.get_collision_normal()
		var hit_object := _ray.get_collider()
		
		player.vfx_manager.spawn_impact(hit_point, hit_normal)
		
		if hit_object.has_method("take_damage"):
			hit_object.take_damage(weapon.damage)
		
	player.vfx_manager.spawn_muzzle_flash()
