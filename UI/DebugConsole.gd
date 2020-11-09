extends Control

func echo(text):
	text = str(text)
	$ConsoleDisplay.text = $ConsoleDisplay.text + text + "\n"

func _on_RunButton_pressed():
	var instruction = $ConsoleInput.text
	echo("$ " + instruction)
	
	var command = instruction.split(" ")[0]
	var args = instruction.split(" ")
	args.remove(0)
	
	if(command == "help"):
		echo("help give save load legal gravity movespeed jumpspeed")
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
	elif(command == "gravity"):
		if(len(args) == 0):
			echo(Physics.GRAVITY)
		else:
			Physics.GRAVITY = int(args[0])
	elif(command == "movespeed"):
		if(len(args) == 0):
			echo(Physics.MOVE_SPEED)
		else:
			Physics.MOVE_SPEED = int(args[0])
	elif(command == "jumpspeed"):
		if(len(args) == 0):
			echo(Physics.JUMP_SPEED)
		else:
			Physics.JUMP_SPEED = int(args[0])
	
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
