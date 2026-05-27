extends Area2D
class_name Door

# ===== 门：切换房间 =====
@export var target_scene: String = ""
@export var target_spawn: String = "spawn_default"

func is_interactable() -> bool:
	return true

func interact(_player: Node) -> void:
	if target_scene.is_empty():
		return
	
	# 播放声音（占位）
	# 切换场景
	var main = get_tree().root.get_node("Main")
	if main and main.has_method("load_room"):
		main.load_room(target_scene, target_spawn)
