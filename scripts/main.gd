# Coordinates the generation and drawing of road segments and buildings

extends Node2D

const CityGen = preload("res://scripts/city_gen.gd")

@onready var city_gen: CityGen = $"../CityGen"
@onready var population_heatmap = $"../PopulationHeatmap"

var generated_segments = []
var generated_buildings = []

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

func _ready():
	populate_options_values()
	randomize()
	run()

func _draw():
	for segment in generated_segments:
		var width = 20 if segment.metadata.highway else 1
		draw_line(segment.start, segment.end, Color8(161, 175, 165), width)
	for building in generated_buildings:
		var corners = building.generate_corners()
		draw_colored_polygon(corners, Color8(12, 22, 31), [], null)

func run():
	for segment in generated_segments:
		segment.free()
	for building in generated_buildings:
		building.free()

	city_gen.randomize_heatmap()
	generated_segments = city_gen.generate_segments()
	generated_buildings = city_gen.generate_buildings(generated_segments)

	# trigger redraw
	queue_redraw()

func _on_GenerateButton_pressed():
	run()

func _on_HeatmapCheckbox_toggled(button_pressed):
	population_heatmap.visible = button_pressed

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
