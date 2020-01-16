extends KinematicBody2D

export (int) var speed = 200

var velocity = Vector2()
var Bullet = preload("res://Bullet.tscn")
var Explosion = preload("res://Explode.tscn")
var MAX_BULLETS = 5
var shotready = true

signal dead

onready var joystick_move := $UI/Move
onready var joystick_look := $UI/Shoot

func joystick_get_input():
	if joystick_move and joystick_move.is_working:
		$Sprite.rotation = joystick_move.output.normalized().angle() - PI/2
		velocity = move_and_slide(joystick_move.output * speed)
	
	if joystick_look and joystick_look.is_working:
		$Sprite2.rotation = joystick_look.output.angle() - PI/2
		var all_bullets = get_tree().get_nodes_in_group("bullets")
		if len(all_bullets) < MAX_BULLETS and shotready:
			shoot()
			shotready = false
			$ShootDelay.start()

func get_input():
	$Sprite2.rotation = get_global_mouse_position().angle_to_point(position) - PI/2
	velocity = Vector2()
	if Input.is_action_pressed('right'):
	    velocity.x += 1
	if Input.is_action_pressed('left'):
	    velocity.x -= 1
	if Input.is_action_pressed('down'):
	    velocity.y += 1
	if Input.is_action_pressed('up'):
	    velocity.y -= 1
	velocity = velocity.normalized() * speed
	$Sprite.rotation = velocity.normalized().angle() - PI/2
	if Input.is_action_just_pressed("click"):
		var all_bullets = get_tree().get_nodes_in_group("bullets")
		print(all_bullets)
		if len(all_bullets) < MAX_BULLETS:
			shoot()

func _physics_process(delta):
    #get_input()
	joystick_get_input()
    #velocity = move_and_slide(velocity)

func shoot():
	var b = Bullet.instance()
	b.add_to_group('bullets')
	b.start($Sprite2.global_position + Vector2(40, 0).rotated($Sprite2.rotation + PI/2), $Sprite2.rotation + PI/2)
	get_parent().add_child(b)
	
func hit():
	var e = Explosion.instance()
	e.start(position)
	get_parent().add_child(e)
	emit_signal("dead")
	queue_free()

func _on_ShootDelay_timeout():
	shotready = true
