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

@onready var sample_sustain = {}
var sample_release = {}

var playing_note = Note.REST
var input_note = Note.REST
var playing_note_node = null
var input_enabled = false
var autoplay = false

func _ready():
    for note in Note.values():
        if note == Note.REST:
            continue
        sample_sustain[note] = get_node("sustain_" + Note.keys()[note].to_lower())
        sample_release[note] = get_node("release_" + Note.keys()[note].to_lower())

func _process(delta):
    if not input_enabled:
        return
    var previous_note = input_note
    input_note = Note.REST
    for note in Note.values():
        if note == Note.REST:
            continue
        if Input.is_action_pressed(Note.keys()[note]):
            input_note = note

    if autoplay:
        for note_node in get_tree().get_nodes_in_group("notes"):
            if note_node.should_be_played():
                input_note = note_node.note

    if previous_note != input_note:
        if input_note != Note.REST:
            # PLAY NOTE
            playing_note = input_note
            for sr in sample_release.keys():
                sample_release[sr].stop()
            sample_sustain[playing_note].play()
            release_timer = 0.0

            # Try to play note in song
            var nearest_note_node = null
            for note_node in get_tree().get_nodes_in_group("notes"):
                if not note_node.can_be_played():
                    continue
                if playing_note != note_node.note:
                    continue
                if nearest_note_node == null or (note_node.position.x < nearest_note_node.position.x):
                    nearest_note_node = note_node
            if nearest_note_node != null:
                nearest_note_node.play(playing_note)
                playing_note_node = nearest_note_node
                
        for note in Note.values():
            if note == Note.REST:
                continue
            if note != playing_note:
                sample_sustain[note].stop()

    if playing_note != Note.REST and input_note == Note.REST:
        release_timer += delta
    if release_timer >= RELEASE_DELAY:
        # RELEASE NOTE
        sample_sustain[playing_note].stop()
        sample_release[playing_note].play()
        playing_note = Note.REST
        release_timer = 0.0

        if playing_note_node != null:
            playing_note_node.release()
            playing_note_node = null
