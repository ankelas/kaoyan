extends Node

# ===== 玩家状态 =====
var energy: int = 80
var max_energy: int = 100

var study_progress: int = 0
var max_study_progress: int = 100

var happiness: int = 60
var max_happiness: int = 100

var day: int = 1
var max_days: int = 30

# ===== 考试相关 =====
var exam_count: int = 0
var exam_total_score: int = 0
var current_exam_score: int = 0

# ===== 事件信号 =====
signal stat_changed
signal day_changed(new_day: int)
signal exam_finished(score: int, total: int)
signal game_over

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func change_energy(amount: int) -> void:
	energy = clampi(energy + amount, 0, max_energy)
	if energy == 0:
		end_day()
	stat_changed.emit()

func change_study(amount: int) -> void:
	study_progress = clampi(study_progress + amount, 0, max_study_progress)
	stat_changed.emit()

func change_happiness(amount: int) -> void:
	happiness = clampi(happiness + amount, 0, max_happiness)
	stat_changed.emit()

func end_day() -> void:
	day += 1
	energy = 80
	happiness = maxi(happiness - 5, 0)
	day_changed.emit(day)
	stat_changed.emit()
	if day > max_days:
		game_over.emit()

func finish_exam(score: int) -> void:
	exam_count += 1
	exam_total_score += score
	current_exam_score = score
	exam_finished.emit(score, exam_total_score)

func get_average_score() -> float:
	if exam_count == 0:
		return 0.0
	return float(exam_total_score) / exam_count

func reset_game() -> void:
	energy = 80
	study_progress = 0
	happiness = 60
	day = 1
	exam_count = 0
	exam_total_score = 0
	current_exam_score = 0
	stat_changed.emit()
	day_changed.emit(day)
