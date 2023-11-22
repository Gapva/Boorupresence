extends Panel

var booru = BRPC.boorus[0]
var tags = []
var ptags = []
var forced = []

func _ready():
	
	$"../fade".show()
	$"../fade".color = Color(0, 0, 0, 1)
	
	$"../ver".text = ProjectSettings.get_setting("application/config/version_name")
	$vbox/current/go/tip.text = booru.locator
	
	$bgm.connect("toggled", bgmtog)
	$update.connect("pressed", updrpc)
	$vbox/current.connect("item_selected", updbooru)
	$vbox/taginput.connect("text_changed", updtags)
	$vbox/tags/clear.connect("pressed", clrtags)
	$vbox/current/go.connect("pressed", gotobooru)
	$vbox/current/go.connect("mouse_entered", entertip)
	$vbox/current/go.connect("mouse_exited", exittip)
	$vbox/taginput/bulk.connect("pressed", bulkdl)
	$vbox/taginput/limit.connect("value_changed", limupd)
	get_viewport().connect("files_dropped", viewtags)
	
	for iterbooru in BRPC.boorus:
		$vbox/current.add_item(iterbooru.alias, iterbooru.id)
	
	await get_tree().create_timer(0.75).timeout
	$"../anims".play("intro")
	await get_tree().create_timer(2).timeout
	$"../fade".hide()
	
	$"../age".connect("confirmed", ageconf)
	$"../age".connect("canceled", agenotice)
	$"../age".popup_centered()
	

func ageconf():
	expresscaution()
#	$vbox/current.clear()

func agenotice():
	forced.append("rating:g")
	$"../warning".connect("confirmed", expresscaution)
	$"../warning".popup_centered()

func expresscaution():
	$"../caution".popup_centered()

func bgmtog(togbool: bool):
	if togbool:
		$"../aud".stream_paused = false
		$bgm/off.hide()
	else:
		$"../aud".stream_paused = true
		$bgm/off.show()

func entertip():
	$vbox/current/go/tip/anims.stop()
	$vbox/current/go/tip/anims.play("inhover")

func exittip():
	$vbox/current/go/tip/anims.stop()
	$vbox/current/go/tip/anims.play("outhover")

func updallinfo():
	BRPC.details = "Viewing " + booru.alias
	if not tags == []:
		BRPC.state = "Tags: " + ", ".join(ptags)
	else:
		BRPC.state = "Homepage"
	if not forced == []:
		BRPC.simg = BRPC.safetylisting[int(bool(true))]
		BRPC.stxt = BRPC.safetyaliases[int(bool(true))]
	else:
		BRPC.simg = BRPC.safetylisting[int(bool(booru.safe))]
		BRPC.stxt = BRPC.safetyaliases[int(bool(booru.safe))]
	$vbox/taglist.text = "\n".join(ptags)
	print("Tags list updated to " + str(forced + tags))

func updbooru(sel: int):
	booru = BRPC.boorus[sel]
	$vbox/current/go/tip.text = booru.locator
	if not booru.has("requrl"):
		$vbox/taginput/bulk.hide()
		$vbox/taginput/limit.hide()
	else:
		$vbox/taginput/bulk.show()
		$vbox/taginput/limit.show()
	BRPC.clearcache()
	updallinfo()

func updtags(new: String):
	if new.right(1) == " " and not tags.has(new.to_lower()):
		tags.append(new.to_lower().replace(" ", ""))
		ptags.append(new.capitalize())
		$vbox/taginput.text = ""
		$"../newtag".play()
	updallinfo()

func clrtags():
	tags = []
	ptags = []
	$"../deltagportion".play()
	$vbox/tags/clear/anims.stop()
	$vbox/tags/clear/anims.play("back")
	updallinfo()

func gotobooru():
	$"../updrpc".play()
	$vbox/current/go/anims.stop()
	$vbox/current/go/anims.play("roll")
	OS.shell_open(booru.locator)

func bulkdl():
	BRPC.updrpc()
	if not tags == []:
		$"../updrpc".play()
		$vbox/taginput/bulk/anims.stop()
		$vbox/taginput/bulk/anims.play("roll")
		BRPC.clearcache()
		if not booru.safe:
			if not forced == [] and not booru.safe:
				BRPC.sendreq(booru, forced + tags)
			else:
				var cleaned = []
				for tag in tags:
					if not tag.to_lower().contains("rating"):
						cleaned.append(tag)
				BRPC.sendreq(booru, forced + cleaned)
		else:
			BRPC.sendreq(booru, tags)
		OS.shell_open(OS.get_user_data_dir() + "/loaded/")
	else:
		$"../deltagportion".play()

func limupd(new: int):
	BRPC.pid = new
	print("Changed bulk-cache page to " + str(new))

func viewtags(file):
	var id = file[0].get_file().split(".")[0].split("-")[1]
	print("Redirecting to post " + id + " on " + booru.alias)
	OS.shell_open(booru.viewurl.format({
		"ID": id
	}))

func updrpc():
	$"../updrpc".play()
	$update/anims.stop()
	$update/anims.play("push")
	BRPC.updrpc()
