extends Node3D

@onready var world_camera = $Overworld_Camera

func become_host():
	print("Become Host Pressed")
	%MultiplayerHUD.hide()
	MultiplayerManager.become_host()
	$CanvasLayer/Crosshair.show()
	world_camera.current = false 

func join_game():
	print("Join Game Pressed")
	%MultiplayerHUD.hide()
	MultiplayerManager.join_game()
	$CanvasLayer/Crosshair.show()
	world_camera.current = false
	
