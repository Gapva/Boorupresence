extends Panel

var booru = BRPC.boorus[0]

func _ready():
	
	$"../fade".show()
	$"../fade".color = Color(0, 0, 0, 1)
	
	$"../ver".text = ProjectSettings.get_setting("application/config/version_name")
	
	$bgm.connect("toggled", bgmtog)
	$update.connect("pressed", updrpc)
	$vbox/current.connect("item_selected", updbooru)
	$vbox/taginput.connect("text_changed", updtags)
	
	for iterbooru in BRPC.boorus:
		$vbox/current.add_item(iterbooru.alias, iterbooru.id)
	
	await get_tree().create_timer(2).timeout
	$"../anims".play("intro")
	await get_tree().create_timer(2).timeout
	$"../fade".hide()

func bgmtog(togbool: bool):
	if togbool:
		$"../aud".playing = true
		$bgm/off.hide()
	else:
		$"../aud".playing = false
		$bgm/off.show()

func updallinfo():
	BRPC.details = "Viewing " + booru.alias
	BRPC.state = "Tags: " + ", ".join($vbox/taglist.text.split("\n"))
	BRPC.simg = BRPC.safetylisting[int(bool(booru.safe))]
	BRPC.stxt = BRPC.safetyaliases[int(bool(booru.safe))]

func updbooru(sel: int):
	booru = BRPC.boorus[sel]
	updallinfo()

func updtags(new: String):
	if new.right(1) == " ":
		$vbox/taglist.text = "\n".join(new.split(" "))
		$"../newtag".play()
	elif new == "":
		$vbox/taglist.text = ""
		$"../deltagportion".play()
	updallinfo()

func updrpc():
	$"../updrpc".play()
	BRPC.updrpc()
