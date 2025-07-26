extends CanvasLayer

@onready var quest_tracker = $QuestTrack
@onready var inventory = $Inventory
@onready var amount = $Inventory/ColorRect/Amount
@onready var quest_tracker_title = $QuestTrack/ColorRect/Details/Title
@onready var quest_tracker_objective = $QuestTrack/ColorRect/Details/Objective

func _ready() -> void:
	hide()
