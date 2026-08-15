class_name Screens


static func main_menu() -> Screen:
	return load("uid://i4jvedvwx3en").instantiate()


static func local_game() -> Screen:
	return load("uid://d2ms6aaidbi2r").instantiate()


static func node_tunnel_game() -> NodeTunnelGame:
	return load("uid://b7seloxwrkdli").instantiate()


static func server_game() -> ServerGame:
	return load("uid://bn41v7yeprjri").instantiate()
