class Segment extends Object:
	var physics_area: RID
	var physics_shape: RID
	var physics_space: RID

	var start: Vector2: set = set_start
	var end: Vector2: set = set_end

	# increments when start or end are changed
	var segment_revision: int = 0

	# time-step delay before this segment is evaluated
	var t: int

	# meta-information relevant to global goals
	var metadata: SegmentMetadata

	# links backwards and forwards
	var links_b: Array = [] # [Segment]
	var links_f: Array = [] # [Segment]
	var road_start: RoadPoint
	var road_end: RoadPoint
	var container: RoadContainer
	
	var previous_segment_to_link = null

	var direction: float: get = get_direction
	var direction_revision: int = -1
	var length: float: get = get_length
	var length_revision: int = -1

	func set_start(v: Vector2):
		start = v
		self.segment_revision += 1

	func set_end(v: Vector2):
		end = v
		self.segment_revision += 1

	func get_direction() -> float:
		if self.direction_revision != self.segment_revision:
			self.direction_revision = self.segment_revision
			var vec = self.end - self.start
			direction = rad_to_deg(-vec.angle()) + 90
		return direction

	func get_length() -> float:
		if self.length_revision != self.segment_revision:
			self.length_revision = self.segment_revision
			length = (self.end - self.start).length()
		return length

	func _init(start_: Vector2, end_: Vector2, t_: int, metadata_: SegmentMetadata):
		self.start = start_
		self.end = end_
		self.t = t_
		self.metadata = metadata_
		self.road_end = RoadPoint.new()
		self.road_start = RoadPoint.new()
		self.container = RoadContainer.new()
		
	func _notification(n):
		if n == NOTIFICATION_PREDELETE:
			self.detach_from_physics_space()

	func connect_road_points(manager: RoadManager):
		manager.add_child(container)
		container.setup_road_container()
		container._auto_refresh = false
		container.add_child(road_start)
		container.add_child(road_end)
		road_start.rotation_degrees.y = self.direction
		road_end.rotation_degrees.y = self.direction
		container.global_position = Vector3(self.start.x, 0, self.start.y)
		road_end.global_position = Vector3(self.end.x, 0, self.end.y)
		road_start.connect_roadpoint(RoadPoint.PointInit.NEXT, road_end, RoadPoint.PointInit.PRIOR)
		#road_end.connect_roadpoint(RoadPoint.PointInit.PRIOR, road_start, RoadPoint.PointInit.NEXT)
		return container
		
	func create_physics_shape() -> RID:
		if self.physics_shape.get_id() == 0:
			self.physics_shape = PhysicsServer2D.rectangle_shape_create()
			var collider_width = Options.HIGHWAY_SEGMENT_WIDTH if self.metadata.highway else Options.NORMAL_SEGMENT_WIDTH
			var shape_data = Vector2(collider_width * 0.5, self.length * 0.5)
			PhysicsServer2D.shape_set_data(self.physics_shape, shape_data)
		return self.physics_shape

	func calculate_physics_shape_transform() -> Transform2D:
		var xform = Transform2D.IDENTITY.rotated(deg_to_rad(-self.direction))
		xform.origin = (self.start + self.end) * 0.5
		return xform

	func destroy_physics_shape():
		if self.physics_shape.get_id() != 0:
			PhysicsServer2D.free_rid(self.physics_shape)
			self.physics_shape = RID()

	func attach_to_physics_space(physics_space_rid: RID):
		assert(physics_space_rid.get_id() != 0)
		self.physics_area = PhysicsServer2D.area_create()
		PhysicsServer2D.area_attach_object_instance_id(self.physics_area, get_instance_id())
		PhysicsServer2D.area_set_monitorable(self.physics_area, false)
		PhysicsServer2D.area_add_shape(self.physics_area, self.create_physics_shape())
		PhysicsServer2D.area_set_shape_transform(self.physics_area, 0, self.calculate_physics_shape_transform())
		PhysicsServer2D.area_set_space(self.physics_area, physics_space_rid)
		self.physics_space = physics_space_rid

	func detach_from_physics_space():
		if self.physics_area.get_id() != 0:
			PhysicsServer2D.free_rid(self.physics_area)
			self.physics_area = RID()
		self.destroy_physics_shape()

	static func new_using_direction(_start: Vector2, _direction: float, _length: float, _t: int, _metadata: SegmentMetadata) -> Segment:
		var new_end := Vector2(_start.x + _length * sin(deg_to_rad(_direction)), _start.y + _length * cos(deg_to_rad(_direction)))
		return Segment.new(_start, new_end, _t, _metadata)

	func start_is_backwards() -> bool:
		if len(self.links_b) > 0:
			return self.links_b[0].start.is_equal_approx(self.start) || self.links_b[0].end.is_equal_approx(self.start)
		elif len(self.links_f) > 0:
			return self.links_f[0].start.is_equal_approx(self.end) || self.links_f[0].end.is_equal_approx(self.end)
		else:
			return false

	func intersection_with(other: Segment):
		var point = Geometry2D.segment_intersects_segment(self.start, self.end, other.start, other.end)
		if point == null:
			return null
		# ignore intersections at segment ends since these are not useful
		if (point.is_equal_approx(self.start) || point.is_equal_approx(self.end) ||
			point.is_equal_approx(other.start) || point.is_equal_approx(other.end)):
			return null
		return point

	func split(point: Vector2, segment: Segment, segments: Array):
		var start_backwards: = self.start_is_backwards()
		var split_part: = self.clone()
		segments.append(split_part)
		split_part.set_end(point)
		self.set_start(point)

		# links are not copied using clone - copy link array for the split part, keeping references the same
		split_part.links_b = self.links_b.duplicate(false)
		split_part.links_f = self.links_f.duplicate(false)

		# work out which links correspond to which end of the split segment
		var first_split: Segment
		var second_split: Segment
		var fix_links: Array
		if start_backwards:
			first_split = split_part
			second_split = self
			fix_links = split_part.links_b
		else:
			first_split = self
			second_split = split_part
			fix_links = split_part.links_f

		for link in fix_links:
			var index = link.links_b.find(self)
			if index != -1:
				link.links_b[index] = split_part
			else:
				index = link.links_f.find(self)
				link.links_f[index] = split_part

		first_split.links_f = [segment, second_split]
		second_split.links_b = [segment, first_split]

		segment.links_f.append(first_split)
		segment.links_f.append(second_split)

		split_part.attach_to_physics_space(self.physics_space)

	func links_for_end_containing(segment: Segment):
		if self.links_b.has(segment):
			return self.links_b
		elif self.links_f.has(segment):
			return self.links_f
		else:
			return null

	func setup_branch_links():
		if self.previous_segment_to_link == null:
			return
		# setup links between each current branch and each existing branch stemming from the previous segment
		for link in self.previous_segment_to_link.links_f:
			self.links_b.append(link)
			link.links_for_end_containing(self.previous_segment_to_link).append(self)
		self.previous_segment_to_link.links_f.append(self)
		self.links_b.append(self.previous_segment_to_link)

	func clone() -> Segment:
		return Segment.new(self.start, self.end, self.t, self.metadata.clone())

class SegmentMetadata:
	var highway: bool = false
	var severed: bool = false

	func clone() -> SegmentMetadata:
		var cloned = SegmentMetadata.new()
		cloned.highway = self.highway
		cloned.severed = self.severed
		return cloned
