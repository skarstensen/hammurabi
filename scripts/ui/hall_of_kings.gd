extends CenterContainer

class_name HighScoreTable

const SAVE_PATH:String = "user://hok.dat"

@export var starIcon:PackedScene
@export var xIcon:PackedScene

@export var scores:Control
@export var nobodyLabel:Label

var entries:Array[HighScoreEntry] = []

func _ready():
	loadScores()
	updateDisplay()


func addEntry(reign, rating):
	var dateDict:Dictionary = Time.get_date_dict_from_system()	
	var dateString:String = "%s/%s/%s" % [dateDict["month"], dateDict["day"], dateDict["year"]]

	entries.append(HighScoreEntry.new(dateString, reign, rating))
	entries.sort_custom(func(e1, e2): return e1.rank > e2.rank)
	
	if (entries.size() > 5):
		entries.remove_at(entries.size() - 1)
	
	updateDisplay()

	saveScores()


func loadScores():
	if (FileAccess.file_exists(SAVE_PATH)):
		var saveFile = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var scoreEntries:int = saveFile.get_8()

		for entry in range(scoreEntries):
			entries.append(HighScoreEntry.new(saveFile.get_pascal_string(), saveFile.get_8(), saveFile.get_8()))


func saveScores():
	var saveFile = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	saveFile.store_8(entries.size())
	
	for entry in entries:
		saveFile.store_pascal_string(entry.date)
		saveFile.store_8(entry.reign)
		saveFile.store_8(entry.rank)


func updateDisplay():
	if (entries.size() == 0):
		nobodyLabel.show()
		scores.hide()
	else:
		nobodyLabel.hide()
		scores.show()
	
	for child in scores.get_children():
		if (child.get_index() >= entries.size()):
			child.hide()
		else:
			child.get_node("Date").text = entries[child.get_index()].date
			child.get_node("Length").text = "%s years" % entries[child.get_index()].reign
			
			for icon in child.get_node("Rank").get_children():
				icon.queue_free()
			
			if (entries[child.get_index()].rank == 0):
				child.get_node("Rank").add_child(xIcon.instantiate())
			else:
				for icon in range(entries[child.get_index()].rank):
					child.get_node("Rank").add_child(starIcon.instantiate())
			
			child.show()


func _on_ok_button_pressed():
	hide()


class HighScoreEntry:
	var date:String
	var reign:int
	var rank:int

	func _init(d:String, ry:int, rs:int):
		date = d
		reign = ry
		rank = rs
