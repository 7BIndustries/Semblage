# Semblage v0.4.0-alpha
import cadquery as cq
# start_params
# end_params
def build_change_me():
    change_me=cq  # {"visible":true}
    change_me=change_me.Workplane().tag("change_me")
    change_me=change_me.box(10,10,10)
    return change_me
change_me=build_change_me()
def build_change_me2():
    change_me2=cq  # {"visible":true}
    change_me2=change_me2.Workplane().tag("change_me2")
    change_me2=change_me2.circle(1.0)
    change_me2=change_me2.extrude(15)
    return change_me2
change_me2=build_change_me2()
