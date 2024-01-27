extends Node
class_name Recorder

enum Note {
    REST,
    C3,
    D3,
    E3,
    F3,
    G3,
    A3,
    B3,
    C4,
    D4,
    E4,
    F4
}

const RELEASE_DELAY = 0.1
var release_timer = 0.0

var sample_sustain = {}
var sample_release = {}

var playing_note = Note.REST
var input_note = Note.REST

func _ready():
    var sample_dir = DirAccess.open("res://recorder/samples")
    sample_dir.list_dir_begin()
    for filename in sample_dir.get_files():
        if filename.ends_with(".import"):
            continue
        var sample_player = AudioStreamPlayer.new()
        sample_player.stream = load("res://recorder/samples/" + filename)
        sample_player.name = filename.to_lower()
        add_child(sample_player)
    
    for note in Note.values():
        if note == Note.REST:
            continue
        sample_sustain[note] = get_node("recorder_sustain_" + Note.keys()[note].to_lower() + "_wav")
        sample_release[note] = get_node("recorder_release_" + Note.keys()[note].to_lower() + "_wav")

func _process(delta):
    var previous_note = input_note
    input_note = Note.REST
    for note in Note.values():
        if note == Note.REST:
            continue
        if Input.is_action_pressed(Note.keys()[note]):
            input_note = note

    if previous_note != input_note:
        if input_note != Note.REST:
            playing_note = input_note
            sample_sustain[playing_note].play()
            release_timer = 0.0
        for note in Note.values():
            if note == Note.REST:
                continue
            if note != playing_note:
                sample_sustain[note].stop()

    if playing_note != Note.REST and input_note == Note.REST:
        release_timer += delta
    if release_timer >= RELEASE_DELAY:
        sample_sustain[playing_note].stop()
        sample_release[playing_note].play()
        playing_note = Note.REST
        release_timer = 0.0