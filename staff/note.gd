extends Node2D

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

func _ready():
    add_to_group("notes")

func set_initial_position():
    position.y = 160 - ((int(note) - 1) * 16)
    position.x = TARGET_X + (note_position * NOTE_X_DIST)
    $bg/label.text = LABEL_VALUE[note]
    $sustain.size.x = NOTE_X_DIST * note_length

func _process(_delta):
    var current_position = note_position - get_parent().beat_timer
    if current_position > 0:
        position.x = TARGET_X + (current_position * NOTE_X_DIST)
    elif current_position >= -note_length:
        position.x = TARGET_X
        $sustain.position.x = current_position * NOTE_X_DIST
    else:
        position.x = TARGET_X + ((current_position + note_length) * NOTE_X_DIST)
