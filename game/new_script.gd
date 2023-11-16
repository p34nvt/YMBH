
extends Node
var ctx = $Canvas.get_canvas_item().get_context("2d")
var score = 0
var first_eat = false
var segments = []
var rdm
var level = 1
var width = OS.get_window_size().width
var height = OS.get_window_size().height
$Canvas.set_custom_mouse_cursor(CursorShape.ARROW)
ctx.canvas_size = Vector2(width, height)
class_name Head
class Head:
	var x = width / 2
	var y = height / 2
	var w = 10
	var h = 20
	var drx = 0
	var dry = 0
	var speed = level
	func colision(obj):
		if (this.x > obj.w && this.y > obj.h && obj.x < this.w && obj.y < this.h):
			return true
		return false
var head = Head.new()
class_name Segment
class Segment:
	var x
	var y
	var w
	var h
	func _init(last):
		x = last.x + last.w + 5
		y = last.y + last.h + 5
		w = last.w
		h = last.h
class_name Mice
class Mice:
	var x
	var y
	var w = 10
	var h = 10
	var dr = 1
	var speed = level
	func _init(x, y):
		x = 1 + randi() % 200
		y = 1 + randi() % 200
		print("cuick")

var mice = Mice.new()
func wall_col(obj):
	if obj.w > width - obj.x && obj.h > height - obj.y:
		return true
	elif obj.x < 1 && obj.y < 1:
		return true
	else:
		return false
func touch_area(cx, cy, x, y, w, h, dr, ev):
	if cx > x && cx < w && cy > y && cy < h:
		dr = ev
var ouroboros = {
	left: true,
	right: true,
	up: false,
	down: true
}
var controller = {
	left: false,
	right: false,
	up: false,
	down: false,
	
	func touch_listener(event):
		var touch_state = event.type == "touchstart" ? true : false
		
		touch_area(event.touches.clientX, event.touches.clientY,
		0, 100, 0, 100, controller.up, touch_state)
		
		touch_area(event.touches.clientX, event.touches.clientY,
		width - 100, width, width - 100, width, controller.down, touch_state)
		
		touch_area(event.touches.clientX, event.touches.clientY,
		0, 100, 0, 100, controller.left, touch_state)
		
		touch_area(event.touches.clientX, event.touches.clientY,
		width - 100, width, width - 100, width, controller.right, touch_state)
	func key_listener(event):
		var key_state = event.type == "keydown" ? true : false
		match event.scancode:
			KEY_LEFT:
				controller.left = key_state
			KEY_UP:
				controller.up = key_state
			KEY_RIGHT:
				controller.right = key_state
			KEY_DOWN:
				controller.down = key_state
		pass
}
func loop():
	if wall_col(head):
		head = null
		ctx.set_fill_color(Color("#ff0000"))
		ctx.set_font("Arial", 30)
		ctx.draw_string("YOU DIED", Vector2(width / 2, height / 2))
	else:
		level = $Level.get_value()
		head.speed = level
		mice.speed = level
		
		ctx.set_fill_color(Color("#000000"))
		ctx.clear_rect(Rect2(0, 0, width, height))
		ctx.set_fill_color(Color("#ffffff"))
		ctx.set_font("Arial", 20)
		ctx.draw_string("hijos down que tuvo tu vieja: " + str(score), Vector2(10, 20))
		
		if head.colision(mice):
			score += 1
			mice = null
			mice = Mice.new()
			first_eat = true
		else:
			rdm = randi() % 101
			print(str(rdm))
			
			if rdm % 2 == 0:
				mice.x += mice.speed
				mice.y += 0
			else:
				mice.x += 0
				mice.y += mice.speed
			
			if wall_col(mice):
				mice.speed *= -mice.dr
			print(str(mice.x) + "\n\n" + str(mice.y) + "\n\n" + str(mice.dr) + "\n\n" + str(mice.speed)
		
		ctx.draw_rect(Rect2(mice.x, mice.y, mice.w, mice.h))
		ctx.draw_rect(Rect2(head.x, head.y, head.w, head.h))
		
		head.x += head.drx
		head.y += head.dry
		
		if controller.up && ouroboros.up:
			ouroboros.left = true
			ouroboros.right = true
			ouroboros.down = false
			head.drx = 0
			head.dry = -1
			head.w = 10
			head.h = 20
		elif controller.down && ouroboros.down:
			ouroboros.left = true
			ouroboros.right = true
			ouroboros.up = false
			head.drx = 0
			head.dry = 1
			head.w = 10
			head.h = 20
		elif controller.left && ouroboros.left:
			ouroboros.up = true
			ouroboros.right = false
			ouroboros.down = true
			head.drx = -1
			head.dry = 0
			head.w = 20
			head.h = 10
		elif controller.right && ouroboros.right:
			ouroboros.left = false
			ouroboros.up = true
			ouroboros.down = true
			head.drx = 1
			head.dry = 0
			head.w = 20
			head.h = 10
		
		var i = 0
		while i < score && first_eat:
			segments[i] = Segment.new(segments[i - 1])
			ctx.draw_rect(Rect2(segments[i].x, segments[i].y, segments[i].w, segments[i].h))
			
			if head.colision(segments[i]):
				segments.remove(i)
			i += 1
		
		yield(get_tree(), "idle_frame")
		#loop()
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) # If you want to hide the mouse cursor
	set_process(true) # Enable the _process function to act as the game loop
	Input.set_custom_mouse_cursor(CursorShape.ARROW) # Set the mouse cursor shape
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			controller.touch_listener(event)
		else:
			controller.touch_listener(event)
	elif event is InputEventKey:
		if event.pressed:
			controller.key_listener(event)
func _process(delta):
	loop() # Call the game loop in the process function
