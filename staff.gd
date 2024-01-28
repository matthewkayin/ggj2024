extends Node2D

@onready var note_scene = preload("res://staff/note.tscn")
@onready var stars = $stars
@onready var bard = get_node("../room/bard")
@onready var king = get_node("../room/king")

var song: Song
var beat_length: float = 0.0
var beat_timer: float = 0.0
var song_length: float = 0.0
var notes_hit: int = 0
var notes_total: int = 0
var score: float = 0.0
var playing = false
var bard_is_playing = false

func _ready():
    stars.visible = false

func open_song():
    var beats_per_second = float(song.bpm) / 60.0
    beat_length = 1.0 / beats_per_second

    bard_is_playing = false
    var note_lines = song.notes.split("\n")
    var note_position: float = beat_length * 4.0
    notes_total = 0
    var note_statements = []
    for line in note_lines:
        if line.begins_with("#"):
            continue
        note_statements.append_array(line.strip_edges().split(" "))
        
    for note_statement in note_statements:
        var parts = note_statement.split(",") if note_statement.contains(",") else [note_statement] 

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

        var note_instance = note_scene.instantiate()
        note_instance.note = note_value
        note_instance.note_length = note_length
        note_instance.note_position = note_position
        add_child(note_instance)
        note_instance.set_initial_position()

        note_position += note_length
        notes_total += 1
    song_length = note_position + 4.0

    beat_timer = 0.0
    notes_hit = 0
    score = 0.0
    stars.visible = true
    stars.set_score(0.0)
    playing = true

func _process(delta):
    if playing:
        beat_timer += delta
        if get_tree().get_nodes_in_group("notes").size() == 0:
            bard.play("idle")
            playing = false

func score_note(note_hit):
    if note_hit:
        notes_hit += 1
        score = float(notes_hit) / float(notes_total)
        stars.lerp_set_score(score)
        if not bard_is_playing:
            bard.play("playing")
            bard_is_playing = true
        if score >= 0.8:
            king.play("smile")
