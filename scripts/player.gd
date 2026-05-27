extends CharacterBody2D

# ===== 移动参数 =====
const SPEED: float = 180.0
const TILE_SIZE: int = 48

# ===== 方向枚举 =====
enum Dir { DOWN, LEFT, RIGHT, UP }

var facing_dir: int = Dir.DOWN
var is_moving: bool = false
var anim_timer: float = 0.0
var anim_frame: int = 0

# ===== 交互系统 =====
var nearby_interactable: Node = null
var is_busy: bool = false          # 对话/考试中禁用移动

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	# 水平翻转默认
	sprite.hframes = 3
	sprite.vframes = 4
	update_sprite()

	# 连接交互信号
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	interaction_area.area_entered.connect(_on_interaction_area_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_area_exited)

func _physics_process(delta: float) -> void:
	if is_busy:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# 输入方向
	var input_dir = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	
	# 更新朝向
	if input_dir.length() > 0.1:
		input_dir = input_dir.normalized()
		is_moving = true
		# 确定主方向
		if absf(input_dir.x) > absf(input_dir.y):
			facing_dir = Dir.RIGHT if input_dir.x > 0 else Dir.LEFT
		else:
			facing_dir = Dir.DOWN if input_dir.y > 0 else Dir.UP
		
		# 动画计时
		anim_timer += delta
		if anim_timer > 0.15:
			anim_timer = 0.0
			anim_frame = (anim_frame + 1) % 3
	else:
		is_moving = false
		anim_frame = 0
		anim_timer = 0.0
	
	velocity = input_dir * SPEED
	move_and_slide()
	update_sprite()
	
	# 交互按键
	if Input.is_action_just_pressed("ui_interact") and nearby_interactable and not is_busy:
		if nearby_interactable.has_method("interact"):
			nearby_interactable.interact(self)

func update_sprite() -> void:
	var row = facing_dir
	sprite.frame = row * 3 + anim_frame

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
