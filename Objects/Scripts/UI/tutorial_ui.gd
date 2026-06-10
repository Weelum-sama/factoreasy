extends CanvasLayer

@onready var objective_label: Label = %ObjectiveLabel

const BEGINNER_TUTORIAL_TEXT: Dictionary = {
	TutorialManager.BEGINNER_TUTORIAL.BUY_NODE: "you can buy things from the store tab on the right,
	buy an iron ore node",
	TutorialManager.BEGINNER_TUTORIAL.PLACE_NODE: "you can place owned ore nodes on the grid,
	select an iron ore node from your inventory and place it on the grid",
	TutorialManager.BEGINNER_TUTORIAL.ATTACH_EXTRACTOR: "extractors can extract ore from nodes,
	select the extractor facility and attach next to the iron ore node",
	TutorialManager.BEGINNER_TUTORIAL.PLACE_BELT: "belts take outputs from facilities and push them onto other facilities' input,
	enter beltmode by pressing 'E' and place a belt on the extractor's output side",
	TutorialManager.BEGINNER_TUTORIAL.FEED_SINK: "sinks can take any item and net you income,
	select the sink facility and place it on the other side of the belt to earn income",
	TutorialManager.BEGINNER_TUTORIAL.DONE: "the factory must grow..."
}



func _ready() -> void:
	TutorialManager.step_changed.connect(_on_tutorial_step_changed)
	_on_tutorial_step_changed(TutorialManager.TUTORIALS.BEGINNER_TUTORIAL, TutorialManager.tutorial_current_step)


func _on_tutorial_step_changed(tutorial: TutorialManager.TUTORIALS, new_step: int) -> void:
	match tutorial:
		TutorialManager.TUTORIALS.BEGINNER_TUTORIAL:
			objective_label.text = BEGINNER_TUTORIAL_TEXT.get(new_step, "")
