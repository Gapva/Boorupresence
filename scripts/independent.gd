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
		"requrl": "https://safebooru.org/index.php?page=dapi&s=post&q=index&pid={PAGE}&tags={TAGS}",
		"viewurl": "https://safebooru.org/index.php?page=post&s=view&id={ID}",
		"safe": true,
		"id": 0
	},
	{
		"alias": "Gelbooru",
		"locator": "https://gelbooru.com/",
		"requrl": "https://gelbooru.com/index.php?page=dapi&s=post&q=index&json=0&pid={PAGE}&tags={TAGS}",
		"viewurl": "https://gelbooru.com/index.php?page=post&s=view&id={ID}",
		"safe": false,
		"id": 1
	},
	{
		"alias": "Konachan (NET)",
		"locator": "https://konachan.net/",
		"requrl": "https://konachan.net/post.xml?&pid={PAGE}&tags={TAGS}",
		"viewurl": "https://konachan.net/post/show/{ID}/",
		"safe": true,
		"id": 2
	},
	{
		"alias": "Konachan (COM)",
		"locator": "https://konachan.com/",
		"requrl": "https://konachan.com/post.xml?&pid={PAGE}&tags={TAGS}",
		"viewurl": "https://konachan.com/post/show/{ID}/",
		"safe": false,
		"id": 3
	},
	{
		"alias": "Yandere",
		"locator": "https://yande.re/",
		"requrl": "https://yande.re/post.xml?&pid={PAGE}&tags={TAGS}",
		"viewurl": "https://yande.re/post/show/{ID}/",
		"safe": false,
		"id": 4
	},
	{
		"alias": "Danbooru",
		"locator": "https://danbooru.donmai.us/",
		"viewurl": "https://danbooru.donmai.us/posts/{ID}/",
		"safe": false,
		"id": 5
	},
]

var http: HTTPRequest
var results: int = 100
var pid: int = 1
var queue: Array = []
var current: String
var ext: String

func _ready():
	if not DirAccess.dir_exists_absolute("user://loaded/"):
		DirAccess.make_dir_absolute("user://loaded/")
	http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", _on_request_completed)

func sendreq(server, tags):
	if pid < 1:
		pid = 1
	var url = server.requrl.format({
		"PAGE": str(pid - 1),
		"TAGS": "+".join(tags)
	})
	print("Requesting images from " + url)
	http.request(url)

func _on_request_completed(result, response_code, headers, body):
	var resp = parseresp(body)
	var images = resp.images
	var ids = resp.ids
	queue = images.slice(0, results - 1)
	for i in range(min(images.size(), results)):
		print("Attempting to cache image from " + images[i])
		current = "{ITERATION}-{ID}".format({
			"ITERATION": i + 1,
			"ID": ids[i]
		})
		ext = "." + images[i].split(".")[-1]
		downloadimg(images[i])
		await http.request_completed
#		if queue.size() > 0:
#			var imgurl = queue.pop_front()
#			http.request(imgurl, [], HTTPClient.METHOD_GET)
#			http.connect("request_completed", on_image_download_completed)

func downloadimg(url: String):
	http.request(url, [], HTTPClient.METHOD_GET)
	http.connect("request_completed", on_image_download_completed)

func on_image_download_completed(result, response_code, headers, body):
	if response_code == 200:
		var path = "user://loaded/" + current + ext
		FileAccess.open(path, FileAccess.WRITE).store_buffer(body)
		print("Finished caching image at " + current)
	else:
		print("Failed to download image from result " + current)

# "i am a never-nester!" my ass
func parseresp(body) -> Dictionary:
	var results = {
		"images": [],
		"ids": []
	}
	var xml = XMLParser.new()
	if xml.open_buffer(body) == OK:
		while xml.read() == OK:
			if xml.get_node_type() == XMLParser.NODE_ELEMENT and xml.get_node_name() == "post":
				var file_url: String = xml.get_named_attribute_value_safe("file_url")
				var post_id: String = xml.get_named_attribute_value_safe("id")
				if file_url.is_empty() or post_id.is_empty():
					var inside_post = true
					while inside_post and xml.read() == OK:
						if xml.get_node_type() == XMLParser.NODE_ELEMENT:
							if xml.get_node_name() == "file_url" and file_url.is_empty():
								xml.read()
								if xml.get_node_type() == XMLParser.NODE_TEXT:
									file_url = xml.get_node_data().strip_edges()
							elif xml.get_node_name() == "id" and post_id.is_empty():
								xml.read()
								if xml.get_node_type() == XMLParser.NODE_TEXT:
									post_id = xml.get_node_data().strip_edges()
						elif xml.get_node_type() == XMLParser.NODE_ELEMENT_END and xml.get_node_name() == "post":
							inside_post = false
						elif xml.is_empty_element() and xml.get_node_name() == "post":
							inside_post = false
							break
				if not file_url.is_empty():
					results["images"].append(file_url)
				if not post_id.is_empty():
					results["ids"].append(post_id)
	return results


func updrpc():
	print("Attempt to refresh presence at " + str(int(Time.get_unix_time_from_system())))
	discord_sdk.details = details
	discord_sdk.state = state
	discord_sdk.large_image = "large"
	discord_sdk.small_image = simg
	discord_sdk.small_image_text = stxt
	discord_sdk.start_timestamp = int(Time.get_unix_time_from_system())
	discord_sdk.refresh()

func clearcache():
	for file in DirAccess.get_files_at("user://loaded"):
			DirAccess.remove_absolute("user://loaded/" + file)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		clearcache()
		get_tree().quit()
