extends Node2D

@onready var note_scene = preload("res://staff/note.tscn")
@onready var score_label = $score_label
@export var song: Song

var beat_length: float = 0.0
var notes = []
var beat_timer: float = 0.0
var score: int = 0
var playing = false

func _ready():
    open_song()

func open_song():
    var beats_per_second = float(song.bpm) / 60.0
    beat_length = 1.0 / beats_per_second

    notes = []
    var note_lines = song.notes.split("\n")
    var note_position: float = beat_length * 4.0
    for line in note_lines:
        if line.begins_with("#"):
            continue
        var parts = line.split(" ")

        var note_length = beat_length
        if parts.size() > 1:
            note_length = float(parts[1]) * beat_length

        if parts[0] == "R":
            note_position += note_length
            continue

        var note_value = null
        for note in Recorder.Note.values():
            if note == Recorder.Note.REST:
                continue
            if parts[0] == Recorder.Note.keys()[note]:
                note_value = note
        if note_value == null:
            print("Error parsing song. Note " + parts[0] + " is not a note.")
            return

        notes.append({
            "note": note_value,
            "position": note_position,
            "length": note_length
        })

        var note_instance = note_scene.instantiate()
        note_instance.note = note_value
        note_instance.note_length = note_length
        note_instance.note_position = note_position
        add_child(note_instance)
        note_instance.set_initial_position()

        note_position += note_length

    beat_timer = 0.0
    score = 0
    score_label.text = "SCORE: 0"
    playing = true

func _process(delta):
    if playing:
        beat_timer += delta

func score_note(score_info):
    if not score_info.hit:
        score += 5
    else:
        score += 5 + score_info.hit_offset
        if score_info.wrong_note:
            score += 15
    score_label.text = "SCORE: " + str(score)