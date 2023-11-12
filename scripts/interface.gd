extends Panel

var booru = BRPC.boorus[0]
var tags = []
var ptags = []

func _ready():
	
	$"../fade".show()
	$"../fade".color = Color(0, 0, 0, 1)
	
	$"../ver".text = ProjectSettings.get_setting("application/config/version_name")
	
	$bgm.connect("toggled", bgmtog)
	$update.connect("pressed", updrpc)
	$vbox/current.connect("item_selected", updbooru)
	$vbox/taginput.connect("text_changed", updtags)
	$vbox/tags/clear.connect("pressed", clrtags)
	$vbox/current/go.connect("pressed", gotobooru)
	$vbox/taginput/bulk.connect("pressed", bulkdl)
	$vbox/taginput/limit.connect("value_changed", limupd)
	
	for iterbooru in BRPC.boorus:
		$vbox/current.add_item(iterbooru.alias, iterbooru.id)
	
	await get_tree().create_timer(3).timeout
	$"../anims".play("intro")
	await get_tree().create_timer(2).timeout
	$"../fade".hide()

func bgmtog(togbool: bool):
	if togbool:
		AudioServer.set_bus_mute(1, false)
		$bgm/off.hide()
	else:
		AudioServer.set_bus_mute(1, true)
		$bgm/off.show()

func updallinfo():
	BRPC.details = "Viewing " + booru.alias
	if not tags == []:
		BRPC.state = "Tags: " + ", ".join(ptags)
	else:
		BRPC.state = "Homepage"
	BRPC.simg = BRPC.safetylisting[int(bool(booru.safe))]
	BRPC.stxt = BRPC.safetyaliases[int(bool(booru.safe))]
	$vbox/taglist.text = "\n".join(ptags)
	print(tags)

func updbooru(sel: int):
	booru = BRPC.boorus[sel]
	updallinfo()

func updtags(new: String):
	if new.right(1) == " " and not tags.has(new.to_lower()):
		tags.append(new.replace(" ", ""))
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
	if booru.has("requrl") and not tags == []:
		$"../updrpc".play()
		$vbox/taginput/bulk/anims.stop()
		$vbox/taginput/bulk/anims.play("roll")
		BRPC.clearcache()
		BRPC.sendreq(booru, tags)
		OS.shell_open(OS.get_user_data_dir() + "/loaded/")
	else:
		$"../deltagportion".play()

func limupd(new: int):
	BRPC.results = new
	print("Changed bulk-cache limit to " + str(new))

func updrpc():
	$"../updrpc".play()
	$update/anims.stop()
	$update/anims.play("push")
	BRPC.updrpc()
