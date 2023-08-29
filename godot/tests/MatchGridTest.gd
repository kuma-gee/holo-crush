extends UnitTest

func before_each():
	Debug.log_level = Debug.Level.INFO
	seed(100)

func _create(initial_data: Array, blocked: Array[Vector2i] = []) -> MatchGrid:
	var data = autofree(MatchGrid.new())
	var level = LevelResource.new()
	level.width = initial_data[0].size()
	level.height = initial_data.size()
	level.blocked = blocked as Array[Vector2i]

	data.level = level
	data.create_data([], initial_data)
	return data

func test_collapse(params=use_parameters([
	[
		[
			[1, 1, 1, 0],
			[0, 1, 2, 0],
			[null, null, null, 1],
			[0, 1, 0, 2]
		],
		[
			[null, null, null, 0],
			[1, 1, 1, 0],
			[0, 1, 2, 1],
			[0, 1, 0, 2]
		]
	],
	[
		[
			[1, 1, 1, 0],
			[0, 1, 2, 0],
			[0, 1, null, 2],
			[0, 1, null, 2]
		],
		[
			[1, 1, null, 0],
			[0, 1, null, 0],
			[0, 1, 1, 2],
			[0, 1, 2, 2]
		]
	]
])):
	var data = _create(params[0])
	data.collapse_columns()
	assert_eq_deep(data.get_data(), params[1])

func test_not_collapse_blocked():
	var data = _create([
			[1, 1, 1, 0],
			[0, 1, 2, 0],
			[0, 1, 2, 2],
			[null, 3, 3, null]
	], [
		Vector2i(0, 3),
		Vector2i(3, 3),
	])

	watch_signals(data)
	data.collapse_columns()
	assert_signal_not_emitted(data, 'moved')


func test_fill_empty(params=use_parameters([
	[
		[
			[1, 1, null, 0],
			[0, 1, null, 0],
			[0, 0, null, 1],
			[0, 1, 0, 2]
		],
		[Vector2i(2, 2), Vector2i(2, 1), Vector2i(2, 0)],
	],
	[
		[
			[1, null, null, null],
			[0, 1, 2, 0],
			[0, 0, 1, 1],
			[0, 1, 0, 2]
		],
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)],
	]
])):
	var data = _create(params[0])
	watch_signals(data)
	data.fill_empty()

	var fill = params[1]
	assert_signal_emit_count(data, 'filled', fill.size())
	for i in fill.size():
		var p = get_signal_parameters(data, 'filled', i)
		assert_eq(p[0], fill[i])

func test_not_fill_blocked():
	var data = _create([
		[1, 1, 0, 0],
		[0, 1, 2, 0],
		[0, 0, 1, 1],
		[0, 1, 0, null]
	], [Vector2(3, 3)])
	watch_signals(data)
	data.fill_empty()

	assert_signal_not_emitted(data, 'filled');

func test_swap_not_match():
	var data = _create([
		[1, 2, 1, 0],
		[0, 1, 2, 0],
		[0, 2, 1, 1],
		[1, 0, 0, 2]
	])

	watch_signals(data)
	data.swap(Vector2(0, 0), Vector2(1, 0))

	assert_signal_emit_count(data, 'wrong_swap', 1)
	assert_contains_exact(get_signal_parameters(data, 'wrong_swap'), [Vector2i(1, 0), Vector2i(0, 0)])
	assert_eq_deep(data.get_data(), [
		[1, 2, 1, 0],
		[0, 1, 2, 0],
		[0, 2, 1, 1],
		[1, 0, 0, 2]
	])


func test_swap_and_collapse_vertical():
	var data = _create([
		[1, 2, 1, 0],
		[0, 1, 2, 0],
		[0, 2, 1, 1],
		[1, 0, 0, 2]
	])

	watch_signals(data)

	data.swap(Vector2(1, 3), Vector2(0, 3))
	data.check_matches()
	assert_signal_emit_count(data, 'matched', 3)
	assert_signal_emitted_in_any_order(data, 'matched', [Vector2i(0, 3), Vector2i(0, 2), Vector2i(0, 1)])

	data.collapse_columns()
	assert_signal_emit_count(data, 'moved', 1)
	assert_signal_emitted_with_parameters(data, 'moved', [Vector2i(0, 0), Vector2i(0, 3)])

	data.fill_empty()
	assert_signal_emit_count(data, 'filled', 3)
	var p = [0, 1, 2].map(func(i): return get_signal_parameters(data, 'filled', i)[0])
	assert_contains_exact(p, [Vector2i(0, 2), Vector2i(0, 1), Vector2i(0, 0)])

func test_swap_and_collapse_horizontal():
	var data = _create([
		[3, 4, 1, 2],
		[0, 3, 4, 3],
		[2, 2, 3, 1],
		[1, 0, 0, 2]
	])

	watch_signals(data)

	data.swap(Vector2(2, 1), Vector2(2, 2))
	data.check_matches()
	assert_signal_emit_count(data, 'matched', 3)
	assert_signal_emitted_in_any_order(data, 'matched', [Vector2i(3, 1), Vector2i(2, 1), Vector2i(1, 1)])

	data.collapse_columns()
	assert_signal_emit_count(data, 'moved', 3)
	assert_signal_emitted_with_parameters(data, 'moved', [Vector2i(1, 0), Vector2i(1, 1)], 0)
	assert_signal_emitted_with_parameters(data, 'moved', [Vector2i(2, 0), Vector2i(2, 1)], 1)
	assert_signal_emitted_with_parameters(data, 'moved', [Vector2i(3, 0), Vector2i(3, 1)], 2)

	data.fill_empty()
	assert_signal_emit_count(data, 'filled', 3)
	var p = [0, 1, 2].map(func(i): return get_signal_parameters(data, 'filled', i)[0])
	assert_contains_exact(p, [Vector2i(3, 0), Vector2i(2, 0), Vector2i(1, 0)])

func test_swap_and_collapse_special_matches(params=use_parameters([
	[
		[
			[0, 4, 1, 2],
			[0, 3, 4, 3],
			[2, 0, 3, 1],
			[0, 2, 1, 2]
		],
		[Vector2(1, 2), Vector2(0, 2)],
		[Vector2i(0, 2), [Vector2i(0, 3), Vector2i(0, 2), Vector2i(0, 1), Vector2i(0, 0)], Specials.Type.ROW],
	],
	[
		[
			[5, 4, 1, 2],
			[1, 3, 4, 3],
			[2, 0, 5, 1],
			[0, 2, 0, 0]
		],
		[Vector2(1, 2), Vector2(1, 3)],
		[Vector2i(1, 3), [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)], Specials.Type.COL],
	],

	[
		[
			[5, 4, 1, 2],
			[1, 0, 4, 3],
			[2, 0, 5, 1],
			[0, 2, 0, 0]
		],
		[Vector2(0, 3), Vector2(1, 3)],
		[Vector2i(1, 3), [Vector2i(1, 3), Vector2i(1, 2), Vector2i(1, 1), Vector2i(2, 3), Vector2i(3, 3)], Specials.Type.BOMB],
	],

	[
		[
			[5, 4, 1, 2],
			[1, 0, 4, 3],
			[0, 2, 0, 0],
			[5, 0, 3, 5]
		],
		[Vector2(0, 2), Vector2(1, 2)],
		[Vector2i(1, 2), [Vector2i(1, 3), Vector2i(1, 2), Vector2i(1, 1), Vector2i(2, 2), Vector2i(3, 2)], Specials.Type.BOMB],
	],

	[
		[
			[5, 0, 1],
			[1, 0, 4],
			[0, 2, 5],
			[5, 0, 2],
			[5, 0, 3]
		],
		[Vector2(0, 2), Vector2(1, 2)],
		[Vector2i(1, 2), [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3), Vector2i(1, 4)], Specials.Type.COLOR_BOMB],
	],
	[
		[
			[2, 5, 0, 1],
			[3, 1, 0, 4],
			[0, 0, 2, 0],
			[1, 5, 0, 2],
			[2, 5, 0, 3]
		],
		[Vector2(3, 2), Vector2(2, 2)],
		[Vector2i(2, 2), [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3), Vector2i(2, 4), Vector2i(0, 2), Vector2i(1, 2)], Specials.Type.COLOR_BOMB],
	],
])):
	var data = _create(params[0])
	watch_signals(data)

	var move = params[1]
	data.swap(move[0], move[1])

	data.check_matches(move[1])

	var expected = params[2]
	assert_signal_emitted_in_any_order(data, 'matched', expected[1]) 

	var special_match = get_all_signal_parameters(data, 'matched').filter(func(x): return x[0] == expected[0] and x[1] == expected[2])
	assert_eq(special_match.size(), 1, 'Special match not found')

func test_activate_special(params=use_parameters([
	[
		[
			[0, 2, 1, 2],
			[0, 3, 4, 3],
			[1, 0, 3, 1],
			[0, 0, 2, 0]
		],
		[[Vector2(1, 2), Vector2(0, 2)], [Vector2(3, 3), Vector2(2, 3)]],
		Vector2i(0, 3),
		[Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)]
	],
	[
		[
			[8, 7, 6, 5],
			[0, 0, 4, 0],
			[5, 0, 0, 1],
			[7, 3, 0, 3],
		],
		[[Vector2(2, 2), Vector2i(2, 1)], [Vector2i(1, 2), Vector2i(2, 2)]],
		Vector2i(2, 0),
		[Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)]
	],
	[
		[
			[7, 0, 8, 2],
			[6, 0, 5, 3],
			[0, 1, 0, 1],
			[4, 0, 0, 0]
		],
		[[Vector2(1, 3), Vector2i(1, 2)], [Vector2i(1, 2), Vector2i(1, 3)]],
		Vector2i(1, 3),
		[Vector2i(2, 3), Vector2i(3, 3), Vector2i(1, 3), Vector2i(0, 3), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)]
	],
	[
		[
			[7, 0, 8, 2],
			[6, 0, 5, 0],
			[0, 3, 0, 1],
			[2, 0, 9, 0],
			[0, 0, 3, 0]
		],
		[[Vector2(0, 2), Vector2i(1, 2)], [Vector2i(3, 4), Vector2i(2, 4)]],
		Vector2i(1, 4),
		[Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 1), Vector2i(2, 2), Vector2i(3, 3)]
	]
])):
	var data = _create(params[0])
	watch_signals(data)
	for swap in params[1]:
		data.swap(swap[0], swap[1])
		data.check_matches(swap[1])
		data.collapse_columns()
		data.fill_empty()

	assert_signal_emitted(data, 'special_activate', params[2])
	assert_signal_emitted_in_any_order(data, 'matched', params[3])


func test_match_special_with_special():
	var data = _create([
		[2, 0, 1, 2, 5],
		[3, 0, 4, 3, 1],
		[4, 2, 0, 1, 4],
		[1, 0, 5, 3, 1],
		[0, 2, 0, 0, 2]
	])

	watch_signals(data)
	data.swap(Vector2(2, 2), Vector2(1, 2))
	data.check_matches(Vector2(1, 2))
	data.collapse_columns()
	data.fill_empty()

	data.swap(Vector2(1, 3), Vector2(1, 4))
	data.check_matches(Vector2(1, 4))
	data.collapse_columns()
	data.fill_empty()

	assert_signal_emitted_with_parameters(data, 'special_activate', [Vector2i(1, 4), [Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4)]], 0)
	assert_signal_emitted_in_any_order(data, 'matched', [Vector2i(4, 4), Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4)])

	var special_match = get_all_signal_parameters(data, 'matched').filter(func(x): return x[0] == Vector2i(1, 4) and x[1] == Specials.Type.COL)
	assert_eq(special_match.size(), 1, 'Special match not found')

func test_special_activation_immediately_after_matched():
	var data = _create([
		[4, 0, 5, 2],
		[3, 0, 4, 5],
		[5, 2, 0, 1],
		[0, 0, 5, 0],
		[5, 1, 0, 3],
	])

	watch_signals(data)
	data.swap(Vector2(2, 2), Vector2(1, 2))
	data.check_matches()
	data.collapse_columns()
	data.fill_empty()

	data.swap(Vector2(2, 4), Vector2(2, 3))
	data.check_matches()
	data.collapse_columns()
	data.fill_empty()

	assert_signal_emit_count(data, 'special_activate', 2)
	assert_signal_emitted_with_parameters(data, 'special_activate', [Vector2i(1, 3), [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)]], 0)
	assert_signal_emitted_with_parameters(data, 'special_activate', [Vector2i(2, 3), [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3), Vector2i(2, 4)]], 1)

	assert_signal_emitted_in_any_order(data, 'matched', [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3), Vector2i(2, 4)])

func test_deadlocked(params=use_parameters([
	[
		[
			[2, 0, 2, 4],
			[2, 2, 1, 2],
			[1, 3, 4, 3],
			[2, 2, 3, 1]
		],
		false
	],

	[
		[
			[2, 0, 5, 4],
			[5, 2, 1, 2],
			[1, 5, 4, 3],
			[2, 2, 3, 1]
		],
		true,
	]
])):
	var data = _create(params[0])
	assert_eq(data.is_deadlocked(), params[1])


func test_refill_on_deadlocked():
	var data = _create([
		[2, 2, 0, 2],
		[5, 0, 1, 2],
		[1, 3, 4, 3],
		[0, 2, 5, 1]
	])

	watch_signals(data)
	data.swap(Vector2i(3, 0), Vector2i(2, 0))
	data.check_matches()
	data.collapse_columns()
	data.fill_empty()
	data.check_deadlock()

	assert_signal_emitted(data, 'refilled')


func test_activate_all_specials():
	var data = _create([
		[2, 2, 0, 2],
		[5, 0, 2, 2],
		[1, 3, 4, 3],
		[0, 2, 5, 1]
	])

	watch_signals(data)
	data.swap(Vector2i(2, 0), Vector2i(2, 1))
	data.check_matches()

	data.activate_all_specials()

	assert_signal_emitted_with_parameters(data, 'special_activate', [Vector2i(2, 0), [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)]])
	assert_signal_emitted_in_any_order(data, 'matched', [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)])

func test_get_possible_move(params=use_parameters([
	[
		[
			[2, 2, 0, 2],
			[5, 0, 1, 2],
			[1, 3, 4, 3],
			[0, 2, 5, 1]
		],
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(3, 0)]
	],
	[
		[
			[2, 2, 0, 1],
			[5, 2, 4, 2],
			[1, 3, 4, 3],
			[0, 2, 5, 1]
		],
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 3)]
	],
	[
		[
			[2, 1, 0, 1],
			[5, 2, 4, 2],
			[1, 3, 4, 3],
			[0, 2, 5, 1]
		],
		null
	]
])):
	var data = _create(params[0])

	var move = data.get_possible_move()
	if params[1] != null:
		assert_not_null(move)
		assert_contains_exact(move, params[1])
	else:
		assert_null(move)
