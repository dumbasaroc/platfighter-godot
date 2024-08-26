@tool

class_name EnvironmentalCollisionBox
extends Node3D

@export_category("CollisionPoints")
@export var _top_point: float = 1
@export var _bottom_point: float = -1
@export var _forward_point: float = 1
@export var _behind_point: float = -1

var _center_point: Vector2 = Vector2(0, 0)
var _debug_sprite: Sprite3D = Sprite3D.new()

var is_editor: bool = false

var _top_point_marker: Marker3D

## Creates a new ECB object with the provided
## point values.
##
## - top_point: Y value for the head of the character
## - bottom_point: Y value for the feet of the character
## - front_point: X value for the furthest forward position
##   of the character
## - back_point: X value for the furthest backward position
##   of the character
func _init(top_point: float, bottom_point: float, front_point: float,
	back_point: float):
		self._top_point = top_point
		self._bottom_point = bottom_point
		self._forward_point = front_point
		self._behind_point = back_point

# Called when the node enters the scene tree for the first time.
func _ready():
	self.is_editor = Engine.is_editor_hint()
	if self.is_editor:
		_debug_sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
		_debug_sprite.texture = load("res://Debug/Sprites/ecb.png")
		_debug_sprite.no_depth_test = true
		_debug_sprite.visible = true
		add_child(_debug_sprite)
	else:
		_debug_sprite.visible = false

# Logic for editor things
func editor_process(scaleX, scaleY):
	if not self.is_editor:
		return
	_debug_sprite.position.x = _center_point.x
	_debug_sprite.position.y = _center_point.y
	_debug_sprite.scale.x = scaleX
	_debug_sprite.scale.y = scaleY


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var scaleY: float = _top_point - _bottom_point
	var scaleX: float = _forward_point - _behind_point
	self._center_point = Vector2(
		_behind_point + (_forward_point - _behind_point)/2,
		_bottom_point + (_top_point - _bottom_point)/2
	)
	
	editor_process(scaleX, scaleY)
