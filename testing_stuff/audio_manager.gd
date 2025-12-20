extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SfxPlayer
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

var voice_by_id: Dictionary = {
	#"intro_hello": preload("res://audio/voice/intro_hello.ogg"),
}

var sfx_by_id: Dictionary = {
	"footsteps": preload("res://testing_stuff/audio/test/Footsteps.ogg"),
}
	

func play_voice(id: String) -> void:
	if not voice_by_id.has(id):
		return
	voice_player.stream = voice_by_id[id]
	voice_player.play()

func play_sfx(id: String) -> void:
	if not sfx_by_id.has(id):
		return
	sfx_player.stream = sfx_by_id[id]
	sfx_player.play()

func _ready():
	pass

func toggle_bg_music():
	if music_player.playing:
		music_player.stop()
	elif not music_player.playing:
		music_player.play()

func play_bg_music():
	music_player.play()
