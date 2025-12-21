class_name RechargingStation extends Interactable


var recharge_text = ""

func do_interaction(): 
	player.is_interacting.emit(self)

	if player.scouting_state.battery == player.scouting_state.battery_max:
		recharge_text += "Scout Battery Fully Charged \n"
	if player.flash_light.battery == player.flash_light.max_battery:
		recharge_text += "Flashlight Fully Charged \n"
	
	my_tween_label.move_above_player(player.player_controller)
	my_tween_label.show_floating(recharge_text)

	recharge_text = ""

	
