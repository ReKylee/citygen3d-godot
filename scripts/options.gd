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
# each 'normal' segment has this probability of producing a branching segment
@export var DEFAULT_BRANCH_PROBABILITY := 0.4
# each 'highway' segment has this probability of producing a branching segment
@export var HIGHWAY_BRANCH_PROBABILITY := 0.05
# delay branching from 'highways' by this amount to prevent them from being blocked by 'normal' segments
@export var NORMAL_BRANCH_TIME_DELAY_FROM_HIGHWAY := 5
# a segment branching off at a 90 degree angle from an existing segment can vary its direction by +/- this amount
@export var BRANCH_ANGLE_DEVIATION := 3 # degrees
# a segment continuing straight ahead from an existing segment can vary its direction by +/- this amount
@export var STRAIGHT_ANGLE_DEVIATION := 15 # degrees
# segments are allowed to intersect if they have a large enough difference in direction - this helps enforce grid-like networks
@export var MINIMUM_INTERSECTION_DEVIATION := 30 # degrees
# only place 'normal' segments when the population is high enough
@export var NORMAL_BRANCH_POPULATION_THRESHOLD := 0.5
# only place 'highway' segments when the population is high enough
@export var HIGHWAY_BRANCH_POPULATION_THRESHOLD := 0.5
# allow a segment to intersect with an existing segment within this distance
@export var MAX_SNAP_DISTANCE := 70 # world units
# the maximum distance that a building can be placed from a selected segment
@export var MAX_BUILDING_DISTANCE_FROM_SEGMENT := 400.0 # world units

# New config options in https://github.com/okorn-src/citygen-godot/
# normal segment width
@export var NORMAL_SEGMENT_WIDTH := 10 # world units
# highway segment width
@export var HIGHWAY_SEGMENT_WIDTH := 25 # world units
# optional world generation seed (integer) -
# used for heatmap, segments and buildings BUT only recreates the same world for a given set of options (see above)
@export var WORLD_SEED := 0 # world seed (int64); 0 = randomize
