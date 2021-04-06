from godot import exposed, export
from godot import *


@exposed
class AboutDialog(AcceptDialog):

	# member variables here, example:
	a = export(int)
	b = export(str, default='foo')

	contribs = ["jmwright (GitHub)"]
	sponsors = ["Ferdinand (Patreon)", "adam-james (Patreon)", "Anonymous"]

	tab_head = "[center][b]Semblage v0.1.0-alpha[/b]\nOpen Source CAD[/center]"
	contribs_str = "[center][b]Contributors[/b]\njmwright (GitHub)[/center]"
	sponsors_str = "[center][b]Sponsors[/b]"
	libs = ""
	docs = ""

	def _ready(self):
		"""
		Called every time the node is added to the scene.
		Initialization here.
		"""

		self.sponsors_str += self._randomize(self.sponsors) + "[/center]"

		# Set the tab headers
		ack_head = self.get_node("AboutTabContainer/Acknowledgements/AckLabel")
		ack_head.bbcode_text = self.tab_head + "\n\n" + self.contribs_str + "\n\n" + self.sponsors_str
		docs_head = self.get_node("AboutTabContainer/Docs/DocsLabel")
		docs_head.bbcode_text = self.tab_head
		info_head = self.get_node("AboutTabContainer/Info/InfoLabel")
		info_head.bbcode_text = self.tab_head

	def _randomize(self, names):
		"""
		Called to randomize the list of names into a string that 
		can be displayed.
		"""

		name_str = "\n"

#		self.randomize()
		rand_user = randi() % names.length()

		name_str += names[rand_user] + "\n"

		# Collect the names
		for name in names:
			name_str += name + "\n"

		return name_str
