extends CanvasLayer
## QuestUI - hiển thị danh sách quest + tiến độ ở góc màn hình.
## Lắng nghe QuestManager để cập nhật.

@onready var _list: VBoxContainer = $Root/Panel/VBox/List

var _labels: Dictionary = {}  # quest_id -> Label

func _ready() -> void:
	layer = 14
	_build()
	QuestManager.quest_updated.connect(_on_quest_updated)
	QuestManager.quest_completed.connect(_on_quest_completed)

func _build() -> void:
	for child in _list.get_children():
		child.queue_free()
	_labels.clear()
	for quest in QuestManager.all_quests():
		var label: Label = Label.new()
		label.add_theme_font_size_override("font_size", 18)
		_list.add_child(label)
		_labels[quest.quest_id] = label
		_update_label(quest, QuestManager.get_progress(quest), QuestManager.is_completed(quest))

func _update_label(quest: QuestData, progress: int, completed: bool) -> void:
	var label: Label = _labels.get(quest.quest_id)
	if label == null:
		return
	var mark: String = "✔" if completed else "•"
	label.text = "%s %s (%d/%d)" % [mark, quest.title, progress, quest.required_amount]
	label.modulate = Color(0.6, 1.0, 0.6) if completed else Color.WHITE

func _on_quest_updated(quest: QuestData, progress: int, completed: bool) -> void:
	_update_label(quest, progress, completed)

func _on_quest_completed(quest: QuestData) -> void:
	_update_label(quest, quest.required_amount, true)
