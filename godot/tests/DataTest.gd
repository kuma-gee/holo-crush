extends UnitTest

func before_each():
	Debug.log_level = Debug.Level.INFO
	seed(100)

func _create(initial_data: Array) -> Data:
	var data = autofree(Data.new())
	var height = initial_data.size()
	var width = initial_data[0].size()

	var values = []
	for i in initial_data:
		for j in i:
			if not j in values and j != null:
				values.append(j)

	data.create_data(values)
	data.set_data(initial_data as Array[Array])
	data.width = width
	data.height = height
	return data
	

func test_matches():
	var data = _create([
		[1, 1, 1, 0],
		[0, 1, 2, 0],
		[0, 2, 1, 1],
		[0, 1, 0, 2]
	])
	
	assert_eq_deep(data.get_matches(0, 0), [])
	assert_eq_deep(data.get_matches(1, 0), [])
	assert_contains_exact(data.get_matches(2, 0), [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)])

	assert_eq_deep(data.get_matches(0, 1), [])
	assert_eq_deep(data.get_matches(0, 2), [])
	assert_contains_exact(data.get_matches(0, 3), [Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)])

func test_matches_both_directions():
	var data = _create([
		[1, 1, 0, 1],
		[2, 1, 0, 2],
		[0, 0, 0, 1],
		[3, 1, 2, 2]
	])
	
	assert_contains_exact(data.get_matches(2, 2), [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(2, 1), Vector2i(2, 0)])

func test_refill():
	var data = _create([
		[1, 1, 1, 0],
		[0, 1, 2, 0],
		[0, 2, 1, 1],
		[0, 1, 0, 2]
	])

	for _i in range(10):
		data.refill_data()
		assert_false(data.check_matches(), "Contains no matches")
		assert_ne_deep(data._data, [
			[1, 1, 1, 0],
			[0, 1, 2, 0],
			[0, 2, 1, 1],
			[0, 1, 0, 2]
		])

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
	data.collapse_columns(false, false)
	assert_eq_deep(data._data, params[1])

func test_fill_empty(params=use_parameters([
	[
		[
			[1, 1, null, 0],
			[0, 1, null, 0],
			[0, 0, null, 1],
			[0, 1, 0, 2]
		],
		[[Vector2i(2, 2), 2], [Vector2i(2, 1), 2], [Vector2i(2, 0), 1]],
	],
	[
		[
			[1, null, null, null],
			[0, 1, 2, 0],
			[0, 0, 1, 1],
			[0, 1, 0, 2]
		],
		[[Vector2i(1, 0), 2], [Vector2i(2, 0), 2], [Vector2i(3, 0), 1]],
	]
])):
	var data = _create(params[0])
	watch_signals(data)
	data.fill_empty()

	var fill = params[1]
	assert_signal_emit_count(data, 'filled', fill.size())
	for i in fill.size():
		assert_signal_emitted_with_parameters(data, 'filled', fill[i], i)

func test_swap_not_match():
	var data = _create([
		[1, 2, 1, 0],
		[0, 1, 2, 0],
		[0, 2, 1, 1],
		[1, 0, 0, 2]
	])

	watch_signals(data)
	data.swap(Vector2(0, 0), Vector2(1, 0))

	assert_signal_emit_count(data, 'swapped', 2)
	assert_signal_emitted_with_parameters(data, 'swapped', [Vector2i(1, 0), Vector2i(0, 0)], 1)
	assert_signal_emitted_with_parameters(data, 'swapped', [Vector2i(0, 0), Vector2i(1, 0)], 0)
	assert_eq_deep(data._data, [
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

	assert_signal_emit_count(data, 'matched', 1)
	assert_signal_emitted_with_parameters(data, 'matched', [[Vector2i(0, 3), Vector2i(0, 2), Vector2i(0, 1)]])

	assert_signal_emit_count(data, 'moved', 1)
	assert_signal_emitted_with_parameters(data, 'moved', [Vector2i(0, 0), Vector2i(0, 3)])

	assert_signal_emit_count(data, 'filled', 3)
	assert_signal_emitted_with_parameters(data, 'filled', [Vector2i(0, 0), 1], 2)
	assert_signal_emitted_with_parameters(data, 'filled', [Vector2i(0, 1), 0], 1)
	assert_signal_emitted_with_parameters(data, 'filled', [Vector2i(0, 2), 0], 0)

	assert_eq_deep(data._data, [
		[1, 2, 1, 0],
		[0, 1, 2, 0],
		[0, 2, 1, 1],
		[1, 1, 0, 2]
	])

func test_swap_and_collapse_horizontal():
	var data = _create([
		[3, 4, 1, 2],
		[0, 3, 4, 3],
		[2, 2, 3, 1],
		[1, 0, 0, 2]
	])

	watch_signals(data)
	data.swap(Vector2(2, 1), Vector2(2, 2))

	assert_signal_emit_count(data, 'matched', 1)
	assert_signal_emitted_with_parameters(data, 'matched', [[Vector2i(3, 1), Vector2i(2, 1), Vector2i(1, 1)]])

	assert_signal_emit_count(data, 'moved', 3)
	assert_signal_emitted_with_parameters(data, 'moved', [Vector2i(1, 0), Vector2i(1, 1)], 0)
	assert_signal_emitted_with_parameters(data, 'moved', [Vector2i(2, 0), Vector2i(2, 1)], 1)
	assert_signal_emitted_with_parameters(data, 'moved', [Vector2i(3, 0), Vector2i(3, 1)], 2)

	assert_signal_emit_count(data, 'filled', 3)
	assert_signal_emitted_with_parameters(data, 'filled', [Vector2i(3, 0), 4], 2)
	assert_signal_emitted_with_parameters(data, 'filled', [Vector2i(2, 0), 2], 1)
	assert_signal_emitted_with_parameters(data, 'filled', [Vector2i(1, 0), 4], 0)

	assert_eq_deep(data._data, [
		[3, 4, 2, 4],
		[0, 4, 1, 2],
		[2, 2, 4, 1],
		[1, 0, 0, 2]
	])

func test_create_special():
	var data = _create([
		[0, 4, 1, 2],
		[0, 3, 4, 3],
		[2, 0, 3, 1],
		[0, 2, 1, 2]
	])

	data.swap(Vector2(1, 2), Vector2(0, 2))

	assert_eq_deep(data._data, [
		[4, 4, 1, 2],
		[2, 3, 4, 3],
		[4, 2, 3, 1],
		[0, 2, 1, 2]
	])

func test_swap_and_collapse_special_matches(params=use_parameters([
	[
		[
			[0, 4, 1, 2],
			[0, 3, 4, 3],
			[2, 0, 3, 1],
			[0, 2, 1, 2]
		],
		[Vector2(1, 2), Vector2(0, 2)],
		[Vector2i(0, 2), [Vector2i(0, 3), Vector2i(0, 2), Vector2i(0, 1), Vector2i(0, 0)], Data.Special.COL],
		Vector2i(0, 3),
	],
	[
		[
			[5, 4, 1, 2],
			[1, 3, 4, 3],
			[2, 0, 5, 1],
			[0, 2, 0, 0]
		],
		[Vector2(1, 2), Vector2(1, 3)],
		[Vector2i(1, 3), [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)], Data.Special.ROW],
		Vector2i(1, 3)
	],

	[
		[
			[5, 4, 1, 2],
			[1, 0, 4, 3],
			[2, 0, 5, 1],
			[0, 2, 0, 0]
		],
		[Vector2(0, 3), Vector2(1, 3)],
		[Vector2i(1, 3), [Vector2i(1, 3), Vector2i(1, 2), Vector2i(1, 1), Vector2i(2, 3), Vector2i(3, 3)], Data.Special.BOMB],
		Vector2i(1, 3)
	],

	[
		[
			[5, 4, 1, 2],
			[1, 0, 4, 3],
			[0, 2, 0, 0],
			[5, 0, 3, 5]
		],
		[Vector2(0, 2), Vector2(1, 2)],
		[Vector2i(1, 2), [Vector2i(1, 3), Vector2i(1, 2), Vector2i(1, 1), Vector2i(2, 2), Vector2i(3, 2)], Data.Special.BOMB],
		Vector2i(1, 3)
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
		[Vector2i(1, 2), [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3), Vector2i(1, 4)], Data.Special.ULT],
		Vector2i(1, 4)
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
		[Vector2i(2, 2), [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3), Vector2i(2, 4), Vector2i(0, 2), Vector2i(1, 2)], Data.Special.ULT],
		Vector2i(2, 4)
	],
])):
	var data = _create(params[0])
	watch_signals(data)

	var move = params[1]
	data.swap(move[0], move[1])

	assert_signal_emit_count(data, 'matched', 1)
	assert_contains_exact(get_signal_parameters(data, 'matched')[0], []) 

	assert_signal_emit_count(data, 'special_matched', 1)

	var actual = get_signal_parameters(data, 'special_matched')
	var expected = params[2]
	assert_eq(actual[0], expected[0])
	assert_contains_exact(actual[1], expected[1])
	assert_eq(actual[2], expected[2])

	assert_eq(data._specials, {params[3]: expected[2]})
	print(data._specials)

func test_activate_special():
	var data = _create([
		[0, 4, 1, 2],
		[0, 3, 4, 3],
		[2, 0, 3, 1],
		[0, 0, 1, 0]
	])

	watch_signals(data)
	data.swap(Vector2(1, 2), Vector2(0, 2))