extends CanvasLayer

@onready var dialogue_label: DialogueLabel = $Conversation/BoxContainer/MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/DialogueLabel
@onready var character_label = $Conversation/BoxContainer/MarginContainer/HBoxContainer/VBoxContainer/CharacterName
@onready var portrait_rect: TextureRect = $Conversation/BoxContainer/MarginContainer/HBoxContainer/ColorRect/SelectedCharacter


@onready var responses_container: VBoxContainer = $Conversation/BoxContainer/MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/ResponsesContainer

@onready var intial_menu = $IntialMenu

@onready var conversation = $Conversation
@onready var player_character = $"../../.."


const MAIN_THEME = preload("uid://w3tinovh7m4s")


var resource: DialogueResource
var dialogue_line: DialogueLine
var is_active := false

const PORTRAITS: Dictionary = {
	"Chris (Dealer)": "res://textures/chris.png",
	"Tony 'Da' Man (Loan Shark)": "res://textures/tony.png",
	"Mama": "res://textures/mama.png",
	"John": "res://textures/johnpork.png",
}

const CHRIS = preload("uid://dk43o81bj0oee")
const JOHNPORK = preload("uid://dkl5en2tu4ty6")
const MAMA = preload("uid://cvfyiqlcyfkfc")
const TONY = preload("uid://dru5p64mjbibq")


func _phone_pickup():
	player_character.in_phone_menu = true
	intial_menu.visible = true
	conversation.visible = false
	
func _talkchris():
	start(CHRIS)
func _talkpork():
	start(JOHNPORK)
func _talkmama():
	start(MAMA)
func _talktony():
	start(TONY)


func start(p_resource: DialogueResource, cue: String = "start") -> void:
	resource = p_resource
	intial_menu.visible = false
	conversation.visible = true
	is_active = true
	show()
	next(cue)

func _ready() -> void:
	DialogueManager.mutated.connect(_on_mutated)

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if dialogue_line and dialogue_line.type == "dialogue":
		if event.is_action_pressed("ui_accept"):
			if dialogue_label.is_typing:
				dialogue_label.skip_typing()
			else:
				next(dialogue_line.next_id)

func next(cue: String) -> void:
	if cue == "" or cue == "end":
		is_active = false
		conversation.visible = false
		player_character.in_phone_menu = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

	dialogue_line = await DialogueManager.get_next_dialogue_line(resource, cue)

	if dialogue_line == null:
		is_active = false
		conversation.visible = false
		player_character.in_phone_menu = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

	if dialogue_line.type == "dialogue":
		_show_speech()
	elif dialogue_line.type == "response":
		_show_responses()

func _show_speech() -> void:
	responses_container.hide()

	character_label.text = dialogue_line.character

	if dialogue_line.character in PORTRAITS:
		portrait_rect.texture = load(PORTRAITS[dialogue_line.character])
		portrait_rect.show()
	else:
		portrait_rect.hide()

	dialogue_label.dialogue_line = dialogue_line
	dialogue_label.type_out()
	await dialogue_label.finished_typing

func _show_responses() -> void:
	for child in responses_container.get_children():
		child.queue_free()

	responses_container.show()
	dialogue_label.hide()
	character_label.text = ""

	var button_theme = MAIN_THEME

	for response in dialogue_line.responses:
		var button := Button.new()
		button.text = response.text
		button.theme = button_theme
		button.pressed.connect(_on_response_selected.bind(response))
		responses_container.add_child(button)

func _on_response_selected(response: DialogueResponse) -> void:
	for child in responses_container.get_children():
		child.queue_free()
	responses_container.hide()
	dialogue_label.show()
	
	next(response.next_id)

func _on_mutated(_mutation: Dictionary) -> void:
	pass
