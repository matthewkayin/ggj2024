extends Sprite2D

@onready var full = $full

var score: float = 0.0
var is_lerping = false

func _ready():
    set_score(0.0)

func set_score(percent: float):
    score = percent

func set_score_floored(percent: float):
    score = 0.2 * floor(percent / 0.2)

func lerp_set_score(percent: float):
    var tween = get_tree().create_tween()
    tween.tween_property(self, "score", percent, 0.1)

func _process(_delta):
    full.region_rect.size.x = 16.0 * 5.0 * score