class_name RechargingStation extends Interactable


var recharge_text = "SCOUT Battery Fully Recharged \n Flashlight Fully Recharged"

func do_interaction(): 
	player.is_interacting.emit(self)
	my_tween_label.move_above_player(player.player_controller)
	my_tween_label.show_floating(recharge_text)
