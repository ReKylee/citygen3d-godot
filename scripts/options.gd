extends Node2D

# generate this number of segments - a higher limit produces larger networks
@export var SEGMENT_COUNT_LIMIT := 2000
# the number of buildings to generate per selected segment
@export var BUILDING_COUNT_PER_SEGMENT := 10
# select every nth segment to place buildings around - a lower period produces denser building placement
@export var BUILDING_SEGMENT_PERIOD := 5
# try to produce 'normal' segments with this length if possible
@export var DEFAULT_SEGMENT_LENGTH := 300 # world units
# try to produce 'highway' segments with this length if possible
@export var HIGHWAY_SEGMENT_LENGTH := 400 # world units
