extends ColorRect

func _ready():
    pass 

func _process(delta):
    if Input.is_action_pressed("right"):
        position.x += 100.0 * delta