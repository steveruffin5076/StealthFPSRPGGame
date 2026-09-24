extends GutTest
## P0-05: ModifierStack aggregation rules.


func test_mult_defaults_to_one() -> void:
	var s: ModifierStack = ModifierStack.new()
	assert_eq(s.get_mult(&"noise_mult"), 1.0)


func test_mults_multiply_and_adds_sum() -> void:
	var s: ModifierStack = ModifierStack.new()
	s.add_source(&"suppressor", { &"noise_mult": 0.2 })
	s.add_source(&"padded_boots", { &"noise_mult": 0.5, &"max_hp_add": 5.0 })
	s.add_source(&"hardened", { &"max_hp_add": 20.0 })
	assert_almost_eq(s.get_mult(&"noise_mult"), 0.1, 0.0001)
	assert_eq(s.get_add(&"max_hp_add"), 25.0)


func test_remove_source() -> void:
	var s: ModifierStack = ModifierStack.new()
	s.add_source(&"a", { &"recoil_mult": 0.5 })
	s.remove_source(&"a")
	assert_eq(s.get_mult(&"recoil_mult"), 1.0)


func test_apply_combines_add_then_mult() -> void:
	var s: ModifierStack = ModifierStack.new()
	s.add_source(&"x", { &"max_hp_add": 20.0, &"max_hp_mult": 1.5 })
	assert_eq(s.apply(&"max_hp", 100.0), 180.0)
