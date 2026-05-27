extends Area2D
class_name RestStation

# ===== 休息点 =====
@export var rest_type: String = "sleep"   # "sleep" 或 "eat"
@export var energy_restore: int = 30
@export var happiness_restore: int = 5

@onready var label: Label = $Label
@onready var cooldown: Timer = $Cooldown

var can_rest: bool = true

func _ready() -> void:
	label.hide()
	cooldown.timeout.connect(_on_cooldown_done)

func is_interactable() -> bool:
	return can_rest

func interact(_player: Node) -> void:
	if not can_rest:
		return
	
	var main = get_tree().root.get_node("Main")
	
	if rest_type == "sleep":
		# 睡觉：恢复精力，消耗时间 → 结束一天
		GameState.change_energy(energy_restore)
		GameState.change_happiness(happiness_restore)
		
		if main:
		 main.show_dialog("你睡了一觉，精力恢复了。\n（按空格键继续）", "休息")
		 await main.dialog_ui.get_node("DialogPanel").dialog_closed
		
		GameState.end_day()
		
	elif rest_type == "eat":
		if GameState.happiness < 5:
			if main:
				main.show_dialog("不饿，吃不下。", "提示")
			return
		
		GameState.change_energy(energy_restore)
		GameState.change_happiness(happiness_restore)
		
		label.text = "+%d 精力" % energy_restore
		label.show()
		var tween = create_tween()
		tween.tween_property(label, "position:y", -40, 0.8)
		tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
		await tween.finished
		label.position.y = 0
		label.modulate.a = 1.0
		label.hide()
		
		can_rest = false
		modulate = Color(0.5, 0.5, 0.5, 0.8)
		cooldown.start(1.0)

func _on_cooldown_done() -> void:
	can_rest = true
	modulate = Color(1, 1, 1, 1)
