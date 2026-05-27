extends CanvasLayer
class_name HUD

var player: Node = null

@onready var energy_bar: ProgressBar = $TopBar/EnergyBar
@onready var study_bar: ProgressBar = $TopBar/StudyBar
@onready var happiness_bar: ProgressBar = $TopBar/HappinessBar
@onready var day_label: Label = $TopBar/DayLabel

func _ready() -> void:
	GameState.stat_changed.connect(_update_bars)
	GameState.day_changed.connect(_on_day_changed)
	_update_bars()

func _update_bars() -> void:
	if not is_inside_tree():
		return
	energy_bar.value = GameState.energy
	energy_bar.max_value = GameState.max_energy
	study_bar.value = GameState.study_progress
	study_bar.max_value = GameState.max_study_progress
	happiness_bar.value = GameState.happiness
	happiness_bar.max_value = GameState.max_happiness
	day_label.text = "第 %d / %d 天" % [GameState.day, GameState.max_days]

func _on_day_changed(_day: int) -> void:
	_update_bars()
