# Coordinates the generation and drawing of road segments and buildings

extends Node2D

const CityGen = preload("res://scripts/city_gen.gd")

@onready var city_gen: CityGen = $"../CityGen"
@onready var population_heatmap = $"../PopulationHeatmap"
@onready var options_menu = $"../UI/OptionsDialogue"

var generated_segments = []
var generated_buildings = []
var rng = RandomNumberGenerator.new()

func _ready():
	populate_options_values()
	randomize()
	run()

func _draw():
	for segment in generated_segments:
		var width = Options.HIGHWAY_SEGMENT_WIDTH if segment.metadata.highway else Options.NORMAL_SEGMENT_WIDTH
		draw_line(segment.start, segment.end, Color8(161, 175, 165), width)
	for building in generated_buildings:
		var corners = building.generate_corners()
		draw_colored_polygon(corners, Color8(12, 22, 31), [], null)

func run():
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
	
	# trigger redraw
	queue_redraw()


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
	get_node("../UI/OptionsDialogue/SegmentsInput")\
		.set_text(str(Options.SEGMENT_COUNT_LIMIT))
	get_node("../UI/OptionsDialogue/BuildingDensityInput")\
		.set_text(str(Options.BUILDING_COUNT_PER_SEGMENT))
	get_node("../UI/OptionsDialogue/BuildingFrequencyInput")\
		.set_text(str(Options.BUILDING_SEGMENT_PERIOD))
	get_node("../UI/OptionsDialogue/SegmentLengthInput")\
		.set_text(str(Options.DEFAULT_SEGMENT_LENGTH))
	get_node("../UI/OptionsDialogue/HighwaySegmentLengthInput")\
		.set_text(str(Options.HIGHWAY_SEGMENT_LENGTH))
	get_node("../UI/OptionsDialogue/DefaultBranchProbabilityInput")\
		.set_text(str(Options.DEFAULT_BRANCH_PROBABILITY))
	get_node("../UI/OptionsDialogue/HighwayBranchProbabilityInput")\
		.set_text(str(Options.HIGHWAY_BRANCH_PROBABILITY))
	get_node("../UI/OptionsDialogue/BranchAngleDeviationInput")\
		.set_text(str(Options.BRANCH_ANGLE_DEVIATION))
	get_node("../UI/OptionsDialogue/StraightAngleDeviationInput")\
		.set_text(str(Options.STRAIGHT_ANGLE_DEVIATION))
	get_node("../UI/OptionsDialogue/MinIntersectionDeviationInput")\
		.set_text(str(Options.MINIMUM_INTERSECTION_DEVIATION))
	get_node("../UI/OptionsDialogue/BranchPopulationThresholdInput")\
		.set_text(str(Options.NORMAL_BRANCH_POPULATION_THRESHOLD))
	get_node("../UI/OptionsDialogue/HighwayPopulationThresholdInput")\
		.set_text(str(Options.HIGHWAY_BRANCH_POPULATION_THRESHOLD))
	get_node("../UI/OptionsDialogue/MaxSnapDistanceInput")\
		.set_text(str(Options.MAX_SNAP_DISTANCE))
	get_node("../UI/OptionsDialogue/MaxBuildingDistanceInput")\
		.set_text(str(Options.MAX_BUILDING_DISTANCE_FROM_SEGMENT))
	get_node("../UI/OptionsDialogue/NormalSegmentWidthInput")\
		.set_text(str(Options.NORMAL_SEGMENT_WIDTH))
	get_node("../UI/OptionsDialogue/HighwaySegmentWidthInput")\
		.set_text(str(Options.HIGHWAY_SEGMENT_WIDTH))

func refresh_world_seed_display():
	get_node("../UI/SeedInputHBoxContainer/WorldSeedInput")\
		.set_text(str(Options.WORLD_SEED))



