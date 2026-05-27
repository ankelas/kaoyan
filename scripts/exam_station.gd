extends Area2D
class_name ExamStation

# ===== 考试点 =====
@export var exam_name: String = "模拟考试"
@export var min_score: int = 40        # 最低分（完全不学）
@export var max_score: int = 100       # 最高分（学满）

@onready var label: Label = $Label

var can_exam: bool = true

func _ready() -> void:
	label.hide()

func is_interactable() -> bool:
	return can_exam

func interact(_player: Node) -> void:
	if not can_exam:
		return
	
	var main = get_tree().root.get_node("Main")
	if not main:
		return
	
	# 根据学习进度计算分数
	var progress_ratio = float(GameState.study_progress) / GameState.max_study_progress
	var score = int(min_score + (max_score - min_score) * progress_ratio)
	# 加入随机波动 ±5
	score += randi() % 11 - 5
	score = clampi(score, 0, 100)
	
	# 显示考试结果
	var grade = "不及格"
	if score >= 90:
		grade = "优秀"
	elif score >= 75:
		grade = "良好"
	elif score >= 60:
		grade = "及格"
	
	# 标记考试
	can_exam = false
	modulate = Color(0.5, 0.5, 0.5, 0.8)
	
	# 扣精力 + 结束这一天
	GameState.change_energy(-15)
	GameState.finish_exam(score)
	
	# 清空学习进度（考过了归零）
	GameState.study_progress = 0
	
	var msg = "%s 成绩: %d 分 [%s]\n（按空格键继续）" % [exam_name, score, grade]
	main.show_dialog(msg, "考试")
	await main.dialog_ui.get_node("DialogPanel").dialog_closed
	
	GameState.end_day()
