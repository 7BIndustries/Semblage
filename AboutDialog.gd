extends AcceptDialog


var semblage_version = "0.1.0-alpha"

var contribs = ["jmwright (GitHub)"]
var sponsors = ["Ferdinand (Patreon)", "adam-james (Patreon)", "Anonymous", "7B Industries"]

var tab_head = "[center][b]Semblage v" + semblage_version + "[/b]\nOpen Source CAD[/center]"
var libs = ""
var docs = "[center][b]DOCUMENTATION[/b]\n[url=https://semblage.7bindustries.com/en/latest/]Semblage[/url]\n[url=https://cadquery.readthedocs.io/en/latest/]CadQuery[/url]\n[url=https://dev.opencascade.org/doc/overview/html/]OCCT Kernel[/url]"
var info = "[center][b]INFORMATION[/b]\nSemblage Version: " + semblage_version + "\nGodot Version: 3.2.2.stable\nGodot-Python Version: 0.50.0\nCadQuery Version: 2.1\nOCP Version: 7.4.0\nOCCT Version: 7.4.0[/center]"


func _randomize(names):
	"""
	Called to randomize the list of names into a string that 
	can be displayed.
	"""

	var name_str = "\n"

	randomize()
	var rand_user = randi() % names.size()

	name_str += names[rand_user] + "\n"

	# Collect the names, skipping the random entry that was already added
	var i = 0
	for name in names:
		# Skip the entry that has already been added
		if i == rand_user:
			i += 1
			continue
	
		name_str += name + "\n"
	
		i += 1

	return name_str


func _on_AboutDialog_about_to_show():
	"""
	Called when the About dialog is about to become visible.
	"""

	# Build the sponsors string
	var sponsors_str = "[center][b]SPONSORS[/b]"
	sponsors_str += self._randomize(self.sponsors) + "[/center]"

	# Build the contributors string
	var contribs_str = "[center][b]CONTRIBUTORS[/b]"
	contribs_str += self._randomize(self.contribs) + "[/center]"

	# Set the tab headers
	var ack_body = self.get_node("AboutTabContainer/Acknowledgements/AckLabel")
	ack_body.bbcode_text = ""
	ack_body.bbcode_text = self.tab_head + "\n\n" + contribs_str + "\n" + sponsors_str
	var docs_body = self.get_node("AboutTabContainer/Docs/DocsLabel")
	docs_body.bbcode_text = ""
	docs_body.bbcode_text = self.tab_head + "\n\n" + self.docs
	var info_body = self.get_node("AboutTabContainer/Info/InfoLabel")
	info_body.bbcode_text = ""
	info_body.bbcode_text = self.tab_head + "\n\n" + self.info


func _on_DocsLabel_meta_clicked(meta):
	"""
	Called when a user clicks on a documentation link.
	"""
	OS.shell_open(meta)