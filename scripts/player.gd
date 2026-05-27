extends CharacterBody2D

# ===== RPG Maker MV 风格网格移动 =====
const TILE_SIZE: int = 48
const MOVE_SPEED: float = 240.0   # 像素/秒
const MOVE_DELAY: float = 0.08    # 动画帧间隔

# ===== 方向枚举 =====
enum Dir { DOWN, LEFT, RIGHT, UP }

# ===== 网格移动状态 =====
var facing_dir: int = Dir.DOWN
var is_moving: bool = false
var target_pos: Vector2 = Vector2.ZERO
var move_dir: Vector2 = Vector2.ZERO

# ===== 动画状态 =====
var anim_timer: float = 0.0
var anim_frame: int = 0
var was_moving: bool = false

# ===== 交互系统 =====
var nearby_interactable: Node = null
var is_busy: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	sprite.texture = preload("res://assets/rm/characters/Actor1.png")
	sprite.region_enabled = true
	sprite.region_rect = Rect2(0, 0, 144, 192)  # 第一个角色(霍尔德)
	sprite.hframes = 3
	sprite.vframes = 4
	target_pos = position
	update_sprite()
	
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	interaction_area.area_entered.connect(_on_interaction_area_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_area_exited)

func _physics_process(delta: float) -> void:
	if is_busy:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# === 网格移动逻辑 (RPG Maker 风格) ===
	if not is_moving:
		var input_dir = Vector2(
			Input.get_axis("ui_left", "ui_right"),
			Input.get_axis("ui_up", "ui_down")
		)
		
		if input_dir.length() > 0.1:
			input_dir = input_dir.normalized()
			
			# 确定主方向
			if absf(input_dir.x) > absf(input_dir.y):
				move_dir = Vector2(signf(input_dir.x), 0)
				facing_dir = Dir.RIGHT if input_dir.x > 0 else Dir.LEFT
			else:
				move_dir = Vector2(0, signf(input_dir.y))
				facing_dir = Dir.DOWN if input_dir.y > 0 else Dir.UP
			
			# 计算目标网格位置（对齐到网格）
			target_pos = (position / TILE_SIZE).round() * TILE_SIZE + move_dir * TILE_SIZE
			is_moving = true
			anim_frame = 1  # 走路动画
			anim_timer = 0.0
	
	if is_moving:
		# 向目标位置移动
		var dist = target_pos - position
		if dist.length() > 1.0:
			velocity = dist.normalized() * MOVE_SPEED
			move_and_slide()
			
			# 动画循环
			anim_timer += delta
			if anim_timer >= MOVE_DELAY:
				anim_timer = 0.0
				anim_frame = (anim_frame + 1) % 3
				if anim_frame == 0:
					anim_frame = 1  # 0是站立帧，走路只用1和2交替
		else:
			position = target_pos
			is_moving = false
			anim_frame = 0  # 站立
			anim_timer = 0.0
	
	update_sprite()
	
	# 交互按键
	if Input.is_action_just_pressed("ui_interact") and nearby_interactable and not is_busy:
		if nearby_interactable.has_method("interact"):
			nearby_interactable.interact(self)

func update_sprite() -> void:
	sprite.frame = facing_dir * 3 + anim_frame

# ===== 交互区域检测 =====
func _on_interaction_area_body_entered(body: Node) -> void:
	if body.has_method("is_interactable"):
		nearby_interactable = body

func _on_interaction_area_body_exited(body: Node) -> void:
	if body == nearby_interactable:
		nearby_interactable = null

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area.has_method("is_interactable"):
		nearby_interactable = area

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area == nearby_interactable:
		nearby_interactable = null

func set_busy(busy: bool) -> void:
	is_busy = busy
	velocity = Vector2.ZERO
