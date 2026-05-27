# room_base.gd — 房间场景基类
extends Node2D

var tile_size := 48

# 房间地图尺寸（格数）
var room_tiles_w := 20
var room_tiles_h := 14

@onready var floor_texture: Texture2D = preload("res://assets/rm/tilesets/SF_Inside_A4.png")
@onready var furniture_texture: Texture2D = preload("res://assets/rm/tilesets/SF_Inside_B.png")

func _ready() -> void:
	build_tiled_floor()

func build_tiled_floor() -> void:
	var tw = room_tiles_w
	var th = room_tiles_h
	var ts = tile_size
	
	# === 图块坐标 (SF_Inside_A4) ===
	# Row 3 (y=144) = 墙基
	# Row 4 (y=192) = 木地板 col0=深边框, col1=浅木, col2=深木, col3=拼花
	# Row 5 (y=240) = 石地板
	var wall_base_uv := Rect2(0, 144, ts, ts)
	var border_uv   := Rect2(0, 192, ts, ts)
	var light_uv    := Rect2(48, 192, ts, ts)
	var dark_uv     := Rect2(96, 192, ts, ts)
	
	# 先清除旧的 Floor 节点（如果有）
	for child in get_children():
		if child is Sprite2D and child.name.begins_with("Tile_"):
			child.queue_free()
	
	# 铺地板（边框 + 棋盘格）
	for x in range(tw):
		for y in range(th):
			var is_border = (x == 0 or x == tw-1 or y == 0 or y == th-1)
			var uv = border_uv if is_border else (light_uv if (x+y)%2==0 else dark_uv)
			_add_tile("Tile_%d_%d" % [x, y], floor_texture, x*ts + ts/2, y*ts + ts/2, uv, -10)
	
	# 墙脚线覆盖上边和下边
	if wall_base_uv:
		for x in range(tw):
			_add_tile("Tile_base_top_%d" % x, floor_texture, x*ts + ts/2, ts/2, wall_base_uv, -9)
			_add_tile("Tile_base_bot_%d" % x, floor_texture, x*ts + ts/2, (th-1)*ts + ts/2, wall_base_uv, -9)

func _add_tile(name: String, tex: Texture2D, px: float, py: float, uv: Rect2, z: int) -> void:
	var spr := Sprite2D.new()
	spr.name = name
	spr.texture = tex
	spr.region_enabled = true
	spr.region_rect = uv
	spr.position = Vector2(px, py)
	spr.z_index = z
	add_child(spr)
