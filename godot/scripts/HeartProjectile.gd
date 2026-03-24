## HeartProjectile.gd
## Item especial carregado por alguns drones (≈20% de chance).
## Cai com gravidade suave. Só restaura uma vida se o jogador atirar nele.
## Se tocar o chão sem ser atingido, desaparece silenciosamente.
extends RigidBody2D

signal collected  # emitido quando o jogador acerta o coração

var _frozen: bool = false


func _ready() -> void:
	add_to_group("heart_projectile")
	gravity_scale = 0.5  # cai mais devagar que as caixas normais


func launch() -> void:
	# Cai reto para baixo — sem herdar velocidade horizontal do drone
	linear_velocity = Vector2(0.0, randf_range(20.0, 60.0))
	# Leve oscilação para dar sensação de flutuar
	angular_velocity = randf_range(-1.2, 1.2)


func freeze() -> void:
	_frozen = true
	freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
	sleeping = true


func collect() -> void:
	emit_signal("collected")
	queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullet"):
		area.destroy()
		collect()


func _on_body_entered(body: Node) -> void:
	# Desaparece silenciosamente ao tocar o chão — sem penalidade
	if body is StaticBody2D or body.is_in_group("ground"):
		queue_free()


func _physics_process(_delta: float) -> void:
	if _frozen:
		return

	# Remove ao sair da tela pela parte de baixo
	if position.y > get_viewport_rect().size.y + 100.0:
		queue_free()
