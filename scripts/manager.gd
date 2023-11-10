extends Control

func _ready():
	discord_sdk.app_id = 1171989014660784199
	print("Connected? " + str(discord_sdk.get_is_discord_working()))
	
	BRPC.updrpc()
