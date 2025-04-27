extends Node

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var multiplayer_scene = preload("res://scenes/multiplayer_player.tscn")
var _players_spawn_node

func become_host():
	print("Starting Host")
	
	_players_spawn_node = get_tree().get_current_scene().get_node("Players") #en la scene (game) tomamos el nodo players, que es donde spawnean.
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = server_peer
	multiplayer.peer_connected.connect(_add_player_to_game) #cuando se mete alguien al server, se llama a la función _add_player_to_game
	multiplayer.peer_disconnected.connect(_del_player)

	_remove_single_player()
	
	_add_player_to_game(1) #añade al host al juego, que siempre tiene id=1

func join_game():
	print("Player Joining")
	
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = client_peer
	
	_remove_single_player()
	
func _add_player_to_game(id:int):
	print("Player %s joined the game" % id)
	
	var player_to_add = multiplayer_scene.instantiate()
	var pos : = Vector2.from_angle(randf() * 2 * PI)
	player_to_add.position = Vector3(pos.x * 3 * randf(),0, pos.y * 3 * randf()) #spawn en posiciones random
	player_to_add.player_id = id
	player_to_add.name = str(id)
	_players_spawn_node.add_child(player_to_add, true) #añade hijos al nodo players, para que lo conecte
	
	
func _del_player(id:int):
	print("Player %s left the game" % id)
	if not _players_spawn_node.has_node(str(id)): #si no está en la lista lo mantenemos igual, si no, lo echamos
		return
	_players_spawn_node.get_node(str(id)).queue_free()
	
func _remove_single_player():
	print("Remove single player")
	var player_to_remove = get_tree().get_current_scene().get_node("Player")
	player_to_remove.queue_free()
	
