extends Node

var multiplayer_peer = ENetMultiplayerPeer.new()

const PORT = 9999
const ADDRESS = "127.0.0.1"

var connected_peer_ids = []



func become_host():
	print("Becoming Host")
	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	add_player_character(1)  #el host tiene ID = 1
	multiplayer.peer_connected.connect(
		func(new_peer_id):
			await get_tree().create_timer(0.2).timeout
			add_newly_connected_player_character.rpc(new_peer_id)
			rpc_id(new_peer_id, "add_previously_connected_player_characters", connected_peer_ids)
			add_player_character(new_peer_id)
	)
	
func join_game():
	print("Joining game")
	multiplayer_peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = multiplayer_peer

func add_player_character(peer_id):
	connected_peer_ids.append(peer_id)
	var player_character = preload("res://scenes/player/Multiplayer_Player.tscn").instantiate()
	player_character.set_multiplayer_authority(peer_id)
	var _players_location = get_tree().get_current_scene().get_node_or_null("Players")
	if _players_location:
		pass
		#print("Node found!")
	else:
		print("Node not found at add_player_character on multiplayer_manager.gd!")
	_players_location.add_child(player_character)
	
	
@rpc
func add_newly_connected_player_character(new_peer_id):
	add_player_character(new_peer_id)
	
@rpc
func add_previously_connected_player_characters(peer_ids:Array):
	for peer_id in peer_ids:
		add_player_character(peer_id)
