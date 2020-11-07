extends Control

func echo(text):
	$ConsoleDisplay.text = $ConsoleDisplay.text + text + "\n"

func _on_RunButton_pressed():
	var instruction = $ConsoleInput.text
	echo("$ " + instruction)
	
	var command = instruction.split(" ")[0]
	var args = instruction.split(" ")
	args.remove(0)
	
	if(command == "help"):
		echo("help give save load legal")
	elif(command == "give"):
		if(len(args) == 1):
			args.append("1")
		for i in range(0, int(args[1])):
			GlobalData.inventory_add_item(args[0])
	elif(command == "save"):
		GlobalData.serialisation_save()
	elif(command == "load"):
		GlobalData.serialisation_load()
	elif(command == "legal"):
		if($LicenseDisplay.visible):
			$LicenseDisplay.visible = false
		else:
			$LicenseDisplay.visible = true
	
	else:
		echo("Unknown command")
	
	$ConsoleInput.text = ""

func _ready():
	visible = false

func _process(delta):
	if(Input.is_action_just_pressed("toggle_debug")):
		if(visible):
			visible = false
			get_tree().paused = false
		else:
			visible = true
			get_tree().paused = true
