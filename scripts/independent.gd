extends Node

var details = "Out of bounds"
var state = "Setting-up"

var simg = "neutral"
var stxt = "Unknown"

var safetylisting = [
	"unsafe",
	"safe"
]

var safetyaliases = [
	"Potentially Unsafe",
	"Safe"
]

const boorus = [
	{
		"alias": "Safebooru",
		"locator": "https://safebooru.org/",
		"safe": true,
		"id": 0
	},
	{
		"alias": "Danbooru",
		"locator": "https://boorusphere-403.mhyl.repl.co/",
		"safe": false,
		"id": 1
	},
	{
		"alias": "Gelbooru",
		"locator": "https://boorusphere-403.mhyl.repl.co/",
		"safe": false,
		"id": 2
	},
	{
		"alias": "Konachan",
		"locator": "https://boorusphere-403.mhyl.repl.co/",
		"safe": false,
		"id": 3
	},
	{
		"alias": "Yandere",
		"locator": "https://boorusphere-403.mhyl.repl.co/",
		"safe": false,
		"id": 4
	},
]

func updrpc():
	print("Attempt to refresh presence at " + str(int(Time.get_unix_time_from_system())))
	discord_sdk.details = details
	discord_sdk.state = state
	discord_sdk.large_image = "large"
	discord_sdk.small_image = simg
	discord_sdk.small_image_text = stxt
	discord_sdk.start_timestamp = int(Time.get_unix_time_from_system())
	discord_sdk.refresh()
