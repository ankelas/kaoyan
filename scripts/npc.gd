extends Area2D
class_name NPC

# ===== NPC =====
@export var npc_name: String = "路人"
@export var dialog_lines: Array[String] = ["你好！"]
@export var spritesheet: String = "People1"
@export var character_index: int = 0  # 在spritesheet中的角色索引(0-7)
@export var use_rm_format: bool = true  # RPG Maker MV 格式 (576x384)

var current_line: int = 0

func _ready() -> void:
 var tex: Texture2D = null
 if use_rm_format:
  tex = load("res://assets/rm/characters/" + spritesheet + ".png")
 else:
  tex = load("res://assets/sprites/" + spritesheet + ".png")

 if tex and $Sprite2D:
  $Sprite2D.texture = tex
  if use_rm_format:
   # 576x384 spritesheet, 3列x4行每个角色
   $Sprite2D.region_enabled = true
   var col = character_index % 4
   var row = floori(character_index / 4)
   $Sprite2D.region_rect = Rect2(col * 144, row * 192, 144, 192)
   $Sprite2D.hframes = 3
   $Sprite2D.vframes = 4
  else:
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
