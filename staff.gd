extends Node2D

@onready var note_scene = preload("res://staff/note.tscn")

var beat_length: float = 0.0
var notes = []
var beat_timer: float = 0.0
var playing = false

func _ready():
    open_song("res://songs/scales.tres")

func open_song(path: String):
    var song = load(path)

    var beats_per_second = float(song.bpm) / 60.0
    beat_length = 1.0 / beats_per_second

    notes = []
    var note_lines = song.notes.split("\n")
    var note_position: float = beat_length * 4.0
    for line in note_lines:
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
            print("Error parsing song with path " + path + ". Note " + parts[0] + " is not a note.")
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
    playing = true

func _process(delta):
    if playing:
        beat_timer += delta