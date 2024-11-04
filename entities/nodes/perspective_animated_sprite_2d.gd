# An AnimatedSprite2D which splits itself into vertical strips with increasing z-index.
# Needed to allow tall characters to exist without clipping into walls in 3/4 view.
#
# This works by creating a set of Sprite2D with cropped textures which perfectly overlap
# the current frame's texture every time it is updated, with each Sprite on a different z-index.
class_name PerspectiveAnimatedSprite2D extends AnimatedSprite2D


# A value used to adjust the allignment of the sprite vertically relative to z index.
# Respects Z height and can fix issues with the sprite partially clipping in and out of walls when its flush against them.
# TODO: Likely needs a better name and description
@export var z_offset := 3


# References to all the AtlasTexture of the different sliced sprites
@onready var sub_sprites_atlas : Array[AtlasTexture] = []


## Creates a set of z-indexed Sprite2D with preconfigured AtlasTexture crop regions
func _ready() -> void:
	var sprite : Sprite2D
	var max_size := _get_maximum_size()
	centered = false # should always be off for these sprites
	var h : int
	for i in range(ceil(max_size.y / float(MapGlobals.TILE_HEIGHT))):
		h = i * MapGlobals.TILE_HEIGHT
		sprite = Sprite2D.new()
		sprite.centered = false
		sprite.texture = AtlasTexture.new()
		# Each texture is cropped to cover a row of the animation texture rect
		sprite.texture.region = Rect2(0, h, max_size.x, MapGlobals.TILE_HEIGHT)
		sprite.position.y = h
		# Z index decreases top to bottom. The sprite's feet will have 'TILE_HEIGHT' z-index
		sprite.z_index = max_size.y - h - z_offset
		# Store the created Sprite2Ds and AtlasTextures
		sub_sprites_atlas.append(sprite.texture)
		self.add_child(sprite)


## Returns the dimensions of the largest sprite in the sprite_frames ressource
func _get_maximum_size() -> Vector2:
	var max_size := Vector2(0, 0)
	var sprite_size : Vector2
	for anim_name in sprite_frames.get_animation_names():
		for i in sprite_frames.get_frame_count(anim_name):
			sprite_size = sprite_frames.get_frame_texture(anim_name, i).get_size()
			if sprite_size.x > max_size.x:
				max_size.x = sprite_size.x
			if sprite_size.y > max_size.y:
				max_size.y = sprite_size.y
	return max_size


## Called each time the CanvasItem is updated (a new sprite is drawn).
## The current frame's texture is copied to every z-indexed sprite2D.
func _draw() -> void:
	var texture := sprite_frames.get_frame_texture(animation, frame)
	for atlas in sub_sprites_atlas:
		atlas.atlas = texture
