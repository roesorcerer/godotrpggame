extends Node2D

@onready var grass: TileMapLayer = $Grass
@onready var soil_layer: TileMapLayer = $SoilLayer
@onready var decor: TileMapLayer = $World/Decor
@onready var paths: TileMapLayer = $Paths
@onready var fences: TileMapLayer = $World/Fences
@onready var player: CharacterBody2D = $World/CharacterBody2D

## Farm cells are a 16px grid anchored at the ranch origin (SoilLayer is
## drawn half a tile offset on top of it; see paint_soil).
const CELL_SIZE := 16

var dug_cells: Dictionary[Vector2i, bool] = {}


## SHOVEL stays until A-41 removes the tool swing.
func _on_player_tool_use(tool: Enum.Tool, pos: Vector2) -> void:
	var cell := Vector2i((to_local(pos) / CELL_SIZE).floor())
	match tool:
		Enum.Tool.SHOVEL:
			if can_farm(cell) and not dug_cells.has(cell):
				dug_cells[cell] = true
				paint_soil(soil_layer, dug_cells, cell)
			clear_decor(decor.local_to_map(decor.to_local(pos)))


# Checked at the cell centre: farmable grass, not under a path or fence tile,
# and not inside anything with collision (buildings, trees, objects, cliffs).
func can_farm(cell: Vector2i) -> bool:
	var centre := to_global(Vector2(cell * CELL_SIZE) + Vector2.ONE * CELL_SIZE / 2.0)
	return (is_farmable(grass, grass.local_to_map(grass.to_local(centre)))
			and not has_tile(paths, centre)
			and not has_tile(fences, centre)
			and not is_obstructed(centre))


func has_tile(layer: TileMapLayer, pos: Vector2) -> bool:
	return layer.get_cell_source_id(layer.local_to_map(layer.to_local(pos))) != -1

func is_obstructed(pos: Vector2) -> bool:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.exclude = [player.get_rid()]
	return not get_world_2d().direct_space_state.intersect_point(query, 1).is_empty()

func is_farmable(layer: TileMapLayer, map_cell: Vector2i) -> bool:
	var data := layer.get_cell_tile_data(map_cell)
	return data != null and data.get_custom_data("farmable")

# Decor tufts span several tiles, so remove the whole tuft that was hit.
# Tiles stamped from the same piece of art share the same map-cell minus
# atlas-coords offset; a touching neighbour tuft has a different one.
func clear_decor(map_cell: Vector2i) -> void:
	if not is_farmable(decor, map_cell):
		return
	var stamp := map_cell - decor.get_cell_atlas_coords(map_cell)
	var to_check: Array[Vector2i] = [map_cell]
	while not to_check.is_empty():
		var c: Vector2i = to_check.pop_back()
		if is_farmable(decor, c) and c - decor.get_cell_atlas_coords(c) == stamp:
			decor.erase_cell(c)
			to_check.append_array(decor.get_surrounding_cells(c))

# dirt.png is a corner-based sheet drawn on a layer offset by half a tile, so
# each soil tile sits where four cells meet and is picked by which of those
# cells are in `cells` (bits: TL=1, TR=2, BL=4, BR=8; see Data.SOIL_TILES).
func paint_soil(layer: TileMapLayer, cells: Dictionary, cell: Vector2i) -> void:
	for tile in [cell + Vector2i(-1, -1), cell + Vector2i(0, -1), cell + Vector2i(-1, 0), cell]:
		var mask := int(cells.has(tile)) \
			| int(cells.has(tile + Vector2i(1, 0))) << 1 \
			| int(cells.has(tile + Vector2i(0, 1))) << 2 \
			| int(cells.has(tile + Vector2i(1, 1))) << 3
		layer.set_cell(tile, Data.SOIL_SOURCE, Data.SOIL_TILES[mask])
