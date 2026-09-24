extends GutTest
## Save round-trip for GameState.to_dict / from_dict.


func test_round_trip() -> void:
	GameState.skill_points = 3
	GameState.unlocked_skills.assign([&"ghost_1"])
	GameState.collected_intel.assign([&"diary_01"])
	GameState.heat = 42.0
	var data: Dictionary = GameState.to_dict()
	var json: String = JSON.stringify(data)
	var back: Dictionary = JSON.parse_string(json) as Dictionary
	GameState.skill_points = 0
	GameState.heat = 0.0
	GameState.from_dict(back)
	assert_eq(GameState.skill_points, 3)
	assert_eq(GameState.unlocked_skills[0], &"ghost_1")
	assert_eq(GameState.collected_intel[0], &"diary_01")
	assert_almost_eq(GameState.heat, 42.0, 0.01)
