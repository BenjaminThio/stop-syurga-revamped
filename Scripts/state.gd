extends Node

const COMBATING = "combating"
const TAKING_ACTION = "taking_action"
const FIGHT = "fight"
const ACT = "act"
const ITEM = "item"
const MERCY = "mercy"
const GAME_OVER = "game_over"
const AVAILABLE_STATES: Array[String] = [COMBATING, TAKING_ACTION, FIGHT, ACT, ITEM, MERCY, GAME_OVER]
var current_state: String = TAKING_ACTION:
	get:
		return current_state
	set(value):
		if get_stack()[1].source == get_script().get_path():
			current_state = value
		else:
			Debug.log_warning(Debug.PROTECTED_VARIABLE + "Please use \"change_state()\" function instead to change the current state.")

func change_state(new_state: String) -> void:
	new_state = new_state.to_lower()
	if new_state in AVAILABLE_STATES and new_state != current_state:
		current_state = new_state
		if current_state == COMBATING:
			var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
			var battlefield: NinePatchRect = get_tree().get_first_node_in_group("battlefield")
			var villian: Area2D = get_tree().get_first_node_in_group("villian")
			
			battlefield.set_property(Vector2(272, 192), Vector2(440, 336), true)
			#battlefield.shrink()
			await time.sleep(battlefield.transition_time)
			player.respawn()
			villian.attack()
