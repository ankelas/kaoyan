extends Node2D

# ===== 主控制器 =====
var player_scene: PackedScene = preload("res://scenes/player.tscn")
var current_room: Node = null
var active_player: CharacterBody2D = null

@onready var room_container: Node2D = $RoomContainer
@onready var player_container: Node2D = $PlayerContainer
@onready var hud: CanvasLayer = $HUD
@onready var dialog_ui: CanvasLayer = $DialogUI
@onready var screen_fade: ColorRect = $ScreenFade

func _ready() -> void:
	# 创建玩家
	var player = player_scene.instantiate()
	player_container.add_child(player)
	active_player = player
	
	# 连接 HUD
	hud.get_node(".").player = player
	
	# 连接对话框
	dialog_ui.hide()
	
	# 加载初始房间
	load_room("res://scenes/dormitory.tscn", "spawn_bed")
	
	# 连接游戏结束
	GameState.game_over.connect(_on_game_over)

func _process(_delta: float) -> void:
	# 调试快捷键 F5 重置
	if Input.is_key_pressed(KEY_F5):
		_on_game_over()
	# F6 下一日
	if Input.is_key_pressed(KEY_F6):
		GameState.end_day()

func load_room(scene_path: String, spawn_name: String = "spawn_default") -> void:
	# 清空当前房间
	for child in room_container.get_children():
		child.queue_free()
	
	# 淡出
	fade_out()
	
	# 加载新房间
	var room_scene = load(scene_path)
	if room_scene == null:
		push_error("无法加载房间: " + scene_path)
		return
	
	current_room = room_scene.instantiate()
	room_container.add_child(current_room)
	
	# 查找出生点
	var spawn = _find_spawn(current_room, spawn_name)
	if spawn and active_player:
		active_player.global_position = spawn.global_position
	elif active_player:
		active_player.global_position = Vector2(480, 288)
	
	# 通知房间加载完成
	if current_room.has_method("_on_room_loaded"):
		current_room._on_room_loaded()
	
	# 淡入
	fade_in()

func _find_spawn(root: Node, name: String) -> Marker2D:
	for child in root.get_children():
		if child is Marker2D and child.name == name:
			return child
		var found = _find_spawn(child, name)
		if found:
			return found
	return null

func fade_out() -> void:
	screen_fade.color.a = 0.0
	screen_fade.show()
	var tween = create_tween()
	tween.tween_property(screen_fade, "color:a", 1.0, 0.3)

func fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(screen_fade, "color:a", 0.0, 0.3)
	await tween.finished
	screen_fade.hide()

func show_dialog(text: String, npc_name: String = "") -> void:
	if active_player:
		active_player.set_busy(true)
	dialog_ui.show()
	dialog_ui.get_node("DialogPanel").show_dialog(text, npc_name)

func hide_dialog() -> void:
	dialog_ui.hide()
	if active_player:
		active_player.set_busy(false)

func _on_game_over() -> void:
	var avg_score = GameState.get_average_score()
	var msg = "游戏结束！\n你坚持了 %d 天\n参加了 %d 场考试\n平均分: %.1f" % [GameState.day - 1, GameState.exam_count, avg_score]
	show_dialog(msg, "系统")
	# 3秒后重置
	await get_tree().create_timer(3.0).timeout
	hide_dialog()
	GameState.reset_game()
	load_room("res://scenes/dormitory.tscn", "spawn_bed")
