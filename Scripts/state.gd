extends Node

enum {
	FIGHT,
	ACT,
	ITEM,
	MERCY,
	TAKING_ACTION,
	COMBATING,
	FLEE,
	GAME_OVER
}
const AVAILABLE_STATES_COUNT: int = 8
var current_state: int = TAKING_ACTION:
	get:
		return current_state
	set(value):
		if get_stack()[1].source == get_script().get_path():
			current_state = value
		else:
			Debug.log_warning(Debug.PRIVATE_VARIABLE_NOT_ACCESSIBLE + "Please use \"change_state()\" function instead to change the current state.", true)

func change_state(new_state: int) -> void:
	if new_state < AVAILABLE_STATES_COUNT and new_state != current_state:
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
