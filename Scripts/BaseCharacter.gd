@tool
class_name BaseCharacter
extends Node3D

@export_category("Internal Shenanigans")

@export_group("ECB Declaration")
@export var ecb_top_point: float = 0.0:
	set(value):
		ecb_top_point = value
		if self.ECB != null:
			self.ECB._top_point = ecb_top_point
		
@export var ecb_bottom_point: float = 0.0:
	set(value):
		ecb_bottom_point = value
		if self.ECB != null:
			self.ECB._bottom_point = ecb_bottom_point

@export var ecb_front_point: float = 0.0:
	set(value):
		ecb_front_point = value
		if self.ECB != null:
			self.ECB._forward_point = ecb_front_point

@export var ecb_back_point: float = 0.0:
	set(value):
		ecb_back_point = value
		if self.ECB != null:
			self.ECB._behind_point = ecb_back_point


@export_category("Character Attributes")

@export_group("Ground Attributes")
@export var run_speed: float = 1.0

@export_group("Air Attributes")
@export var fall_speed: float = 1.0
@export_range(0.0, 1.0) var gravity: float = 1.0
@export var jump_velocity: float = 0.5


# inner state variables
var ECB: EnvironmentalCollisionBox
var velocity: Vector2 = Vector2(0, 0)

var raycast: RayCast3D = RayCast3D.new()

var is_on_ground: bool = true
var facing_left: bool = false

# Debug thingamajiggers

var is_in_editor = Engine.is_editor_hint()

# Called when the node enters the scene tree for the first time.
func _ready():
	self.ECB = EnvironmentalCollisionBox.new(ecb_top_point,
		ecb_bottom_point, ecb_front_point, ecb_back_point)
	self.add_child(ECB)
	self.add_child(raycast)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_in_editor:
		var _dist_to_ecb_x = (ECB._forward_point + ECB._behind_point) / 2
		var _dist_to_ecb_y = (ECB._top_point + ECB._bottom_point) / 2
		
		var amt_leftright = 0.0
		if Input.is_action_pressed("MoveLeft"):
			amt_leftright -= 1.0
		if Input.is_action_pressed("MoveRight"):
			amt_leftright += 1.0
		
		velocity.x = amt_leftright*delta*run_speed
		
		if Input.is_action_just_pressed("Jump") and is_on_ground:
			velocity.y = jump_velocity
			is_on_ground = false
		
		# gravity
		velocity.y = max(velocity.y - gravity*fall_speed*delta, -fall_speed)
		
		raycast.global_position = Vector3(self.global_position.x + _dist_to_ecb_x,
			self.global_position.y + ECB._bottom_point, self.global_position.z)
		var target: Vector3 = Vector3()
		if is_on_ground:
			raycast.position.y += 1
			target.y -= 1.5
		if velocity.y < 0:
			target.y += velocity.y
		raycast.target_position = target
		raycast.force_raycast_update()
		
		
		
		if raycast.is_colliding():
			var collision_point = raycast.get_collision_point()
			self.position.y = collision_point.y - ECB._bottom_point
			velocity.y = 0
			is_on_ground = true
		#else, move character normally
		else:
			self.position = Vector3(position.x, position.y + velocity.y, position.z)

		self.position.x += velocity.x
