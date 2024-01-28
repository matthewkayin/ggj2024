extends Node2D

@onready var song_menu = $room/song_menu
@onready var recorder = $recorder
@onready var staff = $staff
@onready var bard = $room/bard
@onready var king = $room/king

enum State {
    MENU,
    SONG
}

var state: State = State.MENU
var awaiting = false

func _ready():
    bard.play("idle")
    king.play("idle")
    song_menu.open()

func _process(_delta):
    if awaiting:
        return
    if state == State.MENU and not song_menu.visible:
        recorder.input_enabled = true
        staff.song = song_menu.get_selected_song()
        staff.open_song()
        state = State.SONG
    elif state == State.SONG and not staff.playing:
        awaiting = true
        var tween = get_tree().create_tween()
        tween.tween_interval(1.0)
        await tween.finished
        if staff.score >= 0.8:
            king.play("laugh")
            await king.animation_finished
        staff.stars.visible = false
        if staff.score > song_menu.high_scores[song_menu.cursor_index]:
            song_menu.high_scores[song_menu.cursor_index] = staff.score
        song_menu.open()
        bard.play("idle")
        king.play("idle")
        state = State.MENU
        awaiting = false
