extends Node

signal players_updated
signal player_updated(id)
signal vote_updated(id)
signal player_index_received()

@export var multiplayer_test = false
@export var use_roles = true
@export var unique_roles = true # won't start with repeated roles
@export var all_roles = true # won't start if all roles aren't selected
@export var min_players = 2 # won't start if there are at least these players
@export var fill_screen = true
@export var test_players: Array[PlayerDataResource] = [] # first one is server
@export var main_scene: PackedScene

var players: Array[Statics.PlayerData] = []
var change_window_scale := true :
	set(value):
		var last_value = change_window_scale
		change_window_scale = value
		if not change_window_scale:
			reset_window_scale()
		elif last_value != value:
			_update_window_scale()

var _is_window_small = false
var _initial_window_scale_mode
var _initial_window_scale_aspect

@onready var player_id: Label = %PlayerId


func _ready() -> void:
	_initial_window_scale_mode = get_window().content_scale_mode
	_initial_window_scale_aspect = get_window().content_scale_aspect
	
	get_window().size_changed.connect(_handle_size_changed)
	_update_window_scale()
	get_tree().node_added.connect(_handle_node_added)
	
	if not OS.is_debug_build():
		multiplayer_test = false
		player_id.hide()


func sort_players() -> void:
	players.sort_custom(func(a, b): return a.index < b.index)


func add_player(player: Statics.PlayerData) -> void:
	var existing_player: Statics.PlayerData = null
	for data in players:
		if data.id == player.id:
			existing_player = data
			break
	if existing_player:
		existing_player.update(player)
	else:
		players.append(player)
	sort_players()
	players_updated.emit()


func remove_player(id: int) -> void:
	for i in players.size():
		if players[i].id == id:
			players.remove_at(i)
			break
	
	if multiplayer.is_server():
		var player_indices: Dictionary = {}
		for i in players.size():
			players[i].index = i
			player_indices[players[i].id] = i
		update_indices.rpc(player_indices)
	players_updated.emit()


func get_player(id: int) -> Statics.PlayerData:
	for player in players:
		if player.id == id:
			return player
	return null


func get_current_player() -> Statics.PlayerData:
	return get_player(multiplayer.get_unique_id())


@rpc("reliable")
func update_indices(player_indices: Dictionary) -> void:
	for player in Game.players:
		if player.id in player_indices:
			player.index = player_indices[player.id]
			if player.id == multiplayer.get_unique_id():
				Debug.index = player.index
				Debug.add_to_window_title("Client %d" % player.index)
	sort_players()
	players_updated.emit()


@rpc("any_peer", "reliable", "call_local")
func set_player_role(id: int, role: Statics.Role) -> void:
	var player = get_player(id)
	player.role = role
	player_updated.emit(id)


func set_current_player_role(role: Statics.Role) -> void:
	set_player_role.rpc(multiplayer.get_unique_id(), role)


@rpc("any_peer", "reliable", "call_local")
func set_player_vote(id: int, vote: bool) -> void:
	var player = get_player(id)
	if not player:
		return
	player.vote = vote
	player_updated.emit(id)
	vote_updated.emit(id)


func set_current_player_vote(vote: bool) -> void:
	set_player_vote.rpc(multiplayer.get_unique_id(), vote)


func reset_votes() -> void:
	for player in players:
		set_player_vote.rpc(player.id, false)


func is_online() -> bool:
	return not multiplayer.multiplayer_peer is OfflineMultiplayerPeer and \
		multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED


func update_player_id() -> void:
	if not OS.is_debug_build():
		return
	if Debug.is_online():
		player_id.show()
		player_id.text = str(multiplayer.get_unique_id())
	else:
		player_id.hide()


func reset_window_scale() -> void:
	get_window().content_scale_mode = _initial_window_scale_mode
	get_window().content_scale_aspect = _initial_window_scale_aspect


func _handle_size_changed() -> void:
	if not change_window_scale:
		return
	
	var was_windows_small = _is_window_small
	#get_window().min_size = Vector2i(1280, 720)
	_is_window_small =  get_window().size.x < 1280 or get_window().size.y < 720

	if was_windows_small == _is_window_small:
		return
	
	_update_window_scale()


func _update_window_scale() -> void:
	if _is_window_small:
		get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	else:
		get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
		get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP


func _handle_node_added(node: Node) -> void:
	if node.get_parent() == get_window():
		# Scene has been changed
		change_window_scale = node is MainMenu or node is LobbyHostScreen or \
			node is LobbyJoinScreen or node is LobbyWaitingScreen or node is Credits
