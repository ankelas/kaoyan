extends Control
class_name DialogPanel

@onready var name_label: Label = $NameLabel
@onready var text_label: RichTextLabel = $TextLabel
@onready var next_indicator: TextureRect = $NextIndicator
@onready var timer: Timer = $TypeTimer

var full_text: String = ""
var current_char: int = 0
var is_typing: bool = false
var is_closing: bool = false

func _ready() -> void:
	hide()
	modulate = Color(1, 1, 1, 0)

func show_dialog(text: String, npc_name: String = "") -> void:
	full_text = text
	current_char = 0
	is_closing = false
	
	name_label.text = npc_name
	text_label.text = ""
	next_indicator.hide()
	
	show()
	# 淡入
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,1), 0.2)
	
	# 开始打字效果
	is_typing = true
	timer.start(0.03)

func _on_type_timer_timeout() -> void:
	if current_char >= full_text.length():
		is_typing = false
		timer.stop()
		next_indicator.show()
		return
	
	current_char += 1
	text_label.text = full_text.substr(0, current_char)

func _input(event: InputEvent) -> void:
	if not visible or modulate.a < 0.5:
		return
	
	if event.is_action_pressed("ui_interact") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		
		if is_typing:
			# 立即显示全文
			is_typing = false
			timer.stop()
			text_label.text = full_text
			current_char = full_text.length()
			next_indicator.show()
		elif not is_closing:
			close_dialog()

func close_dialog() -> void:
	is_closing = true
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.2)
	await tween.finished
	hide()
	
	# 通知 main 解锁玩家
	var main = get_tree().root.get_node("Main")
	if main:
		main.hide_dialog()
