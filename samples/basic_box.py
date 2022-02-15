# Semblage v0.2.0-alpha
import cadquery as cq
# start_params
# end_params
def build_change_me():
    change_me=cq  # {"visible":true}
    change_me=change_me.Workplane("XY").workplane(invert=True,centerOption="CenterOfBoundBox").tag("change_me")
    change_me=change_me.box(10.0,10.0,10.0,centered=(True,True,True),combine=True,clean=True)
    return change_me
change_me=build_change_me()
