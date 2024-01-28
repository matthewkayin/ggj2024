extends Node2D

const ALLOWANCE = 20
const TARGET_X = 135
var NOTE_X_DIST = 28.0 * 4.0
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
var hit_offset: float = 0.0

func _ready():
    add_to_group("notes")

func set_initial_position():
    NOTE_X_DIST = (28.0 * 4.0) * float(get_parent().song.bpm) / 120.0
    position.y = 160 - ((int(note) - 1) * 16)
    position.x = TARGET_X + (note_position * NOTE_X_DIST)
    $bg.frame = int(note) - 1
    $sustain.size.x = NOTE_X_DIST * (note_length - (get_parent().beat_length * 0.2))

func can_be_played():
    return abs(position.x - TARGET_X) <= ALLOWANCE

func should_be_played():
    return position.x <= TARGET_X && position.x + $sustain.size.x >= TARGET_X

func _process(_delta):
    var current_position = note_position - get_parent().beat_timer
    position.x = TARGET_X + (current_position * NOTE_X_DIST)
    if is_being_played:
        if position.x + $sustain.size.x < TARGET_X:
            release()
        $bg.position.x = TARGET_X - position.x - 14
    if position.x < TARGET_X and abs(position.x - TARGET_X) > ALLOWANCE:
        get_parent().score_note(false)
    if position.x + $sustain.size.x < -TARGET_X:
        release()

func play(as_note: Recorder.Note):
    played_as = as_note
    if played_as != note:
        position.y = 160 - ((int(played_as) - 1) * 16)
        $bg.frame = int(note) - 1
    hit_offset = max(abs(position.x - TARGET_X), ALLOWANCE)
    is_being_played = true
    get_parent().score_note(true)

func release():
    is_being_played = false
    queue_free()
