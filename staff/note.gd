extends Node2D

const ALLOWANCE = 30
const TARGET_X = 60
const NOTE_X_DIST = 28.0 * 4.0
const LABEL_VALUE = {
    Recorder.Note.C3: "A",
    Recorder.Note.D3: "S",
    Recorder.Note.E3: "D",
    Recorder.Note.F3: "F",
    Recorder.Note.G3: "G",
    Recorder.Note.A3: "H",
    Recorder.Note.B3: "J",
    Recorder.Note.C4: "K",
    Recorder.Note.D4: "L",
    Recorder.Note.E4: ";",
    Recorder.Note.F4: "\""
}

var note: Recorder.Note
var note_position: float
var note_length: float
var is_being_played: bool = false
var played_as: Recorder.Note

func _ready():
    add_to_group("notes")

func set_initial_position():
    position.y = 160 - ((int(note) - 1) * 16)
    position.x = TARGET_X + (note_position * NOTE_X_DIST)
    $bg/label.text = LABEL_VALUE[note]
    $sustain.size.x = NOTE_X_DIST * (note_length - (get_parent().beat_length * 0.5))

func can_be_played():
    return (position.x >= TARGET_X and position.x - TARGET_X <= ALLOWANCE) or (position.x < TARGET_X && position.x + $sustain.size.x > TARGET_X)

func _process(_delta):
    var current_position = note_position - get_parent().beat_timer
    position.x = TARGET_X + (current_position * NOTE_X_DIST)
    if is_being_played:
        if not can_be_played():
            is_being_played = false
            release()
        $bg.position.x = TARGET_X - position.x - 14
    if position.x + $sustain.size.x < -TARGET_X:
        queue_free()

func play(as_note: Recorder.Note):
    played_as = as_note
    if played_as != note:
        position.y = 160 - ((int(played_as) - 1) * 16)
        $bg/label.text = LABEL_VALUE[played_as]
    is_being_played = true

func release():
    queue_free()