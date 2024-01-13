extends Object

var physics_shape: RID
var physics_area: RID

var center: Vector2
var direction: float
var aspect_ratio: float
var diagonal: float
var corners: PackedVector2Array

func _notification(n):
	if n == NOTIFICATION_PREDELETE:
		self.detach_from_physics_space()

func create_physics_shape() -> RID:
	if self.physics_shape.get_id() == 0:
		self.physics_shape = PhysicsServer2D.convex_polygon_shape_create()
		PhysicsServer2D.shape_set_data(self.physics_shape, PackedVector2Array(self.generate_corners()))
	return self.physics_shape

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
	PhysicsServer2D.area_set_space(self.physics_area, physics_space_rid)

func detach_from_physics_space():
	if self.physics_area.get_id() != 0:
		PhysicsServer2D.free_rid(self.physics_area)
		self.physics_area = RID()
	self.destroy_physics_shape()

func generate_corners() -> PackedVector2Array:
	if len(self.corners) == 0:
		var aspect_degrees = rad_to_deg(atan(self.aspect_ratio))
		self.corners = PackedVector2Array([
			Vector2(
				self.center.x + self.diagonal * sin(deg_to_rad(+aspect_degrees + self.direction)),
				self.center.y + self.diagonal * cos(deg_to_rad(+aspect_degrees + self.direction))
				),
			Vector2(
				self.center.x + self.diagonal * sin(deg_to_rad(-aspect_degrees + self.direction)),
				self.center.y + self.diagonal * cos(deg_to_rad(-aspect_degrees + self.direction))
				),
			Vector2(
				self.center.x + self.diagonal * sin(deg_to_rad(180 + aspect_degrees + self.direction)),
				self.center.y + self.diagonal * cos(deg_to_rad(180 + aspect_degrees + self.direction))
				),
			Vector2(
				self.center.x + self.diagonal * sin(deg_to_rad(180 - aspect_degrees + self.direction)),
				self.center.y + self.diagonal * cos(deg_to_rad(180 - aspect_degrees + self.direction))
				)
			])
	return self.corners
