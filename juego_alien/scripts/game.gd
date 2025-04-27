extends Node3D

func become_host():
	print("Become Host Pressed")
	%MultiplayerHUD.hide()
	MultiplayerManager.become_host()

func join_game():
	print("Join Game Pressed")
	%MultiplayerHUD.hide()
	MultiplayerManager.join_game()
