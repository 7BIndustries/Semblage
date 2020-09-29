import cadquery as cq

result = cq.Workplane("XY").rect(1, 1).extrude(1)

show_object(result)
