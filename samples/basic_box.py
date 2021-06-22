# Semblage v0.2.0-alpha
import cadquery as cq
# start_params
# end_params
change_me=cq
change_me=change_me.Workplane("XY").workplane(invert=True,centerOption="CenterOfBoundBox").tag("change_me")
change_me=change_me.box(10.0,10.0,10.0,centered=(True,True,True),combine=True,clean=True)

show_object(change_me)