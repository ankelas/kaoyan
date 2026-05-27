extends Area2D
class_name StudyStation

# ===== 学习点 =====
@export var efficiency: float = 1.0       # 学习效率倍率
@export var energy_cost: int = 10
@export var study_gain: int = 15

@onready var label: Label = $Label
@onready var cooldown: Timer = $Cooldown

var can_study: bool = true

func _ready() -> void:
	label.hide()
	cooldown.timeout.connect(_on_cooldown_done)

func is_interactable() -> bool:
	return can_study

func interact(_player: Node) -> void:
	if not can_study:
		return
	
	if GameState.energy < energy_cost:
		var main = get_tree().root.get_node("Main")
		if main:
			main.show_dialog("太累了，学不进去了……先休息一下吧。", "提示")
		return
	
	# 学习
	var gain = int(study_gain * efficiency)
	GameState.change_energy(-energy_cost)
	GameState.change_study(gain)
	GameState.change_happiness(-2)
	
	# 显示反馈
	label.text = "+%d 学习进度" % gain
	label.show()
	var tween = create_tween()
	tween.tween_property(label, "position:y", -40, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	await tween.finished
	label.position.y = 0
	label.modulate.a = 1.0
	label.hide()
	
	# 冷却
	can_study = false
	modulate = Color(0.5, 0.5, 0.5, 0.8)
	cooldown.start(0.5)

func _on_cooldown_done() -> void:
	can_study = true
	modulate = Color(1, 1, 1, 1)
