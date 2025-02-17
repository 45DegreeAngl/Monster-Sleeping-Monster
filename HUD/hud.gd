extends Control

var slot_sound = preload("res://Sounds/Jackpot Slot Machine Sounds Effect Casino.wav")
var win_sound = preload("res://Sounds/mixkit-melodic-gold-price-2000.wav")

func _ready():
	Globals.chosen_color_changed.connect(on_objective_change)
	Globals.time_left_changed.connect(on_time_changed)

func play_roll():
	$AudioStreamPlayer.stream = slot_sound
	$AudioStreamPlayer.play()

func play_win():
	$AudioStreamPlayer.stop()
	$AudioStreamPlayer.stream = win_sound
	$AudioStreamPlayer.play()

func on_objective_change():
	$"VBoxContainer/SubViewportContainer/SubViewport/Hunted Guy".set_color(Globals.cur_chosen_color)
	$"VBoxContainer/Hunted Color".text = "HUNTING {0}".format([Globals.colors[Globals.cur_chosen_color]],"{0}")
	$"VBoxContainer/Current Multiplier".text = "MULTIPLIER: {0}".format([Globals.cur_chosen_multiplier],"{0}")


func on_time_changed():
	$Time.text = Globals.format_seconds_as_time(Globals.time_left_in_sec)
	if Globals.time_left_in_sec < 30:
		$Time.modulate = Color.RED
	else:
		$Time.modulate = Color(1,1,1,1)
