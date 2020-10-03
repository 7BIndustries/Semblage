import cadquery as cq

b1 = cq.Solid.makeBox(1, 1, 1)
b2 = cq.Workplane().box(1, 1, 2)
b3 = cq.Workplane().center(-2, -5).box(1, 1, 3)

assy = cq.Assembly(b1, loc=cq.Location(cq.Vector(2, -5, 0)), color=cq.Color("red"))
assy.add(b2, loc=cq.Location(cq.Vector(1, 1, 0)), color=cq.Color("green"))
assy.add(b3, loc=cq.Location(cq.Vector(2, 3, 0)))

show_object(assy)
