extends Area2D
class_name NPC

# ===== NPC =====
@export var npc_name: String = "路人"
@export var dialog_lines: Array[String] = ["你好！"]
@export var spritesheet: String = "classmate"

var current_line: int = 0

func _ready() -> void:
	# 加载对应 spritesheet
	var tex = load("res://assets/sprites/" + spritesheet + ".png")
	if tex and $Sprite2D:
		$Sprite2D.texture = tex
		$Sprite2D.hframes = 3
		$Sprite2D.vframes = 4
		$Sprite2D.frame = 0  # 面向下

func is_interactable() -> bool:
	return true

func interact(_player: Node) -> void:
	var main = get_tree().root.get_node("Main")
	if not main or dialog_lines.is_empty():
		return
	
	# 循环对话
	var line = dialog_lines[current_line]
	current_line = (current_line + 1) % dialog_lines.size()
	
	main.show_dialog(line, npc_name)
