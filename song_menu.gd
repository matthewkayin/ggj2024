extends NinePatchRect

signal finished

@export var songs: Array[Song]

@onready var options = $options.get_children()
@onready var cursor = $cursor

var cursor_index: int = 0
var high_scores = []

func _ready():
    for song in songs:
        high_scores.append(0.0)
    close()

func get_selected_song():
    return songs[cursor_index]

func update_selected_song_score(with_score: float):
    high_scores[cursor_index] = with_score

func update_cursor():
    cursor.position.y = 9 + (12 * cursor_index)

func open():
    for i in range(0, options.size()):
        options[i].text = songs[i].songname
        options[i].get_node("stars").set_score_floored(high_scores[i])
    cursor_index = 0
    update_cursor()
    visible = true

func close():
    visible = false

func _process(_delta):
    if not visible:
        return
    if Input.is_action_just_pressed("enter"):
        emit_signal("finished")
        close()
        return
    if Input.is_action_just_pressed("down"):
        cursor_index = (cursor_index + 1) % 3
        update_cursor()
    if Input.is_action_just_pressed("up"):
        cursor_index = cursor_index - 1
        if cursor_index < 0:
            cursor_index += 3
        update_cursor()