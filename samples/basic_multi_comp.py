# Semblage v0.2.0-alpha
import cadquery as cq
# start_params
# end_params
change_me=cq
change_me2=cq
change_me=change_me.Workplane().tag("change_me")
change_me=change_me.box(10,10,10)
change_me2=change_me2.Workplane().tag("change_me2")
change_me2=change_me2.circle(1.0)
change_me2=change_me2.extrude(15)

show_object(change_me)
show_object(change_me2)