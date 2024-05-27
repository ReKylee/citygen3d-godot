# Coordinates the generation and drawing of road segments and buildings

extends Node3D

const Math = preload("res://scripts/math.gd")
const CityGen = preload("res://scripts/city_gen.gd") 
const seg_mod = preload("res://scripts/segment.gd")
const Segment = seg_mod.Segment
const SegmentMetadata = seg_mod.SegmentMetadata

@onready var city_gen: CityGen = $CityGen
@onready var population_heatmap = $CityGen/PopulationHeatmap
@onready var options_menu = $UI/OptionsDialogue

@onready var road_manager: RoadManager = $RoadManager

var generated_segments = []
var generated_buildings = []
var rng = RandomNumberGenerator.new()


func _ready():
	
	populate_options_values()
	run()
func _process(delta: float) -> void:
	draw()
	pass
	
func draw():
	for segment in generated_segments:
		var width = Options.HIGHWAY_SEGMENT_WIDTH if segment.metadata.highway else Options.NORMAL_SEGMENT_WIDTH
		var s = DebugDraw3D.scoped_config().set_thickness(width/4)
		DebugDraw3D.draw_arrow(Vector3(segment.start.x, 0, segment.start.y), Vector3(segment.end.x, 0, segment.end.y),Color8(161, 175, 165),.2)

	for building in generated_buildings:
		var corners2d = building.generate_corners() as PackedVector2Array
		corners2d.append(corners2d[0])
		var corners3d : PackedVector3Array
		for corner in corners2d:
			corners3d.append(Vector3(corner.x, 0, corner.y))
		var s = DebugDraw3D.scoped_config().set_thickness(2)
		DebugDraw3D.draw_line_path(corners3d, Color8(12, 22, 31))
		

func generate_roads():

	for segment in generated_segments:
		var segment_container = segment.connect_road_points(road_manager) as RoadContainer
	
	for segment in generated_segments:
		var this_container = segment.container
		var links_b = segment.links_b
		var links_f = segment.links_f
		if(links_b.size() == 0):
			return
		if(links_f.size() == 0):
			return
		for seglink in links_b:
			var cont = seglink.container as RoadContainer
			var link_road_end = seglink.road_end as RoadPoint
			link_road_end.connect_container(RoadPoint.PointInit.PRIOR, segment.road_start, RoadPoint.PointInit.NEXT)
		for seglink in links_f:
			var cont = seglink.container as RoadContainer
			var link_road_start = seglink.road_start as RoadPoint
			link_road_start.connect_container(RoadPoint.PointInit.NEXT, segment.road_end, RoadPoint.PointInit.PRIOR)
			
	road_manager.rebuild_all_containers()
	

	
	
func run():
	for child in road_manager.get_children():
		child.free()
	for segment in generated_segments:
		segment.free()
	for building in generated_buildings:
		building.free()

	if (! Options.WORLD_SEED):
		rng.randomize()
		Options.WORLD_SEED = rng.get_seed()
	else:
		rng.set_seed(Options.WORLD_SEED)

	city_gen.randomize_heatmap(rng)
	generated_segments = city_gen.generate_segments(rng)
	generated_buildings = city_gen.generate_buildings(generated_segments, rng)

	print("World seed: ", Options.WORLD_SEED)
	refresh_world_seed_display()
	
	generate_roads()


### GENERATE BUTTON & TOGGLES ###

func _on_GenerateButton_pressed():
	run()

func _on_HeatmapCheckbox_toggled(button_pressed):
	population_heatmap.visible = button_pressed

func _on_OptionsCheckbox_toggled(button_pressed):
	options_menu.visible = button_pressed


### OPTIONS SETTING ###
	
func _on_segments_input_text_changed(new_value):
	Options.SEGMENT_COUNT_LIMIT = new_value

func _on_building_density_input_text_changed(new_value):
	Options.BUILDING_COUNT_PER_SEGMENT = new_value

func _on_building_frequency_input_text_changed(new_value):
	Options.BUILDING_SEGMENT_PERIOD = new_value

func _on_segment_length_input_text_changed(new_value):
	Options.DEFAULT_SEGMENT_LENGTH = new_value

func _on_highway_segment_length_input_text_changed(new_value):
	Options.HIGHWAY_SEGMENT_LENGTH = new_value

func _on_default_branch_probability_input_text_changed(new_value):
	Options.DEFAULT_BRANCH_PROBABILITY = new_value

func _on_highway_branch_probability_input_text_changed(new_value):
	Options.HIGHWAY_BRANCH_PROBABILITY = new_value

func _on_branch_angle_deviation_input_text_changed(new_value):
	Options.BRANCH_ANGLE_DEVIATION = new_value

func _on_straight_angle_deviation_input_text_changed(new_value):
	Options.STRAIGHT_ANGLE_DEVIATION = new_value

func _on_min_intersection_deviation_input_text_changed(new_value):
	Options.MINIMUM_INTERSECTION_DEVIATION = new_value

func _on_branch_population_threshold_input_text_changed(new_value):
	Options.NORMAL_BRANCH_POPULATION_THRESHOLD = new_value

func _on_highway_population_threshold_input_text_changed(new_value):
	Options.HIGHWAY_BRANCH_POPULATION_THRESHOLD = new_value

func _on_max_snap_distance_input_text_changed(new_value):
	Options.MAX_SNAP_DISTANCE = new_value

func _on_max_building_distance_input_text_changed(new_value):
	Options.MAX_BUILDING_DISTANCE_FROM_SEGMENT = new_value

func _on_normal_segment_width_input_text_changed(new_value):
	Options.NORMAL_SEGMENT_WIDTH = new_value

func _on_highway_segment_width_input_text_changed(new_value):
	Options.HIGHWAY_SEGMENT_WIDTH = new_value

func _on_world_seed_input_text_changed(new_value):
	Options.WORLD_SEED = new_value

func populate_options_values():
	options_menu.get_node("SegmentsInput")\
		.set_text(str(Options.SEGMENT_COUNT_LIMIT))
	options_menu.get_node("BuildingDensityInput")\
		.set_text(str(Options.BUILDING_COUNT_PER_SEGMENT))
	options_menu.get_node("BuildingFrequencyInput")\
		.set_text(str(Options.BUILDING_SEGMENT_PERIOD))
	options_menu.get_node("SegmentLengthInput")\
		.set_text(str(Options.DEFAULT_SEGMENT_LENGTH))
	options_menu.get_node("HighwaySegmentLengthInput")\
		.set_text(str(Options.HIGHWAY_SEGMENT_LENGTH))
	options_menu.get_node("DefaultBranchProbabilityInput")\
		.set_text(str(Options.DEFAULT_BRANCH_PROBABILITY))
	options_menu.get_node("HighwayBranchProbabilityInput")\
		.set_text(str(Options.HIGHWAY_BRANCH_PROBABILITY))
	options_menu.get_node("BranchAngleDeviationInput")\
		.set_text(str(Options.BRANCH_ANGLE_DEVIATION))
	options_menu.get_node("StraightAngleDeviationInput")\
		.set_text(str(Options.STRAIGHT_ANGLE_DEVIATION))
	options_menu.get_node("MinIntersectionDeviationInput")\
		.set_text(str(Options.MINIMUM_INTERSECTION_DEVIATION))
	options_menu.get_node("BranchPopulationThresholdInput")\
		.set_text(str(Options.NORMAL_BRANCH_POPULATION_THRESHOLD))
	options_menu.get_node("HighwayPopulationThresholdInput")\
		.set_text(str(Options.HIGHWAY_BRANCH_POPULATION_THRESHOLD))
	options_menu.get_node("MaxSnapDistanceInput")\
		.set_text(str(Options.MAX_SNAP_DISTANCE))
	options_menu.get_node("MaxBuildingDistanceInput")\
		.set_text(str(Options.MAX_BUILDING_DISTANCE_FROM_SEGMENT))
	options_menu.get_node("NormalSegmentWidthInput")\
		.set_text(str(Options.NORMAL_SEGMENT_WIDTH))
	options_menu.get_node("HighwaySegmentWidthInput")\
		.set_text(str(Options.HIGHWAY_SEGMENT_WIDTH))

func refresh_world_seed_display():
	get_node("UI/SeedInputHBoxContainer/WorldSeedInput")\
		.set_text(str(Options.WORLD_SEED))



