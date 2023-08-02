extends UnitTest

func before_each():
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

func test_collapse():
	var data = _create([
		[1, 1, 1, 0],
		[0, 1, 2, 0],
		[null, null, null, 1],
		[0, 1, 0, 2]
	])

	data.collapse_columns(false, false)

	assert_eq_deep(data._data, [
		[null, null, null, 0],
		[1, 1, 1, 0],
		[0, 1, 2, 1],
		[0, 1, 0, 2]
	])


func test_fill_empty():
	var data = _create([
		[1, 1, null, 0],
		[0, 1, null, 0],
		[0, 0, null, 1],
		[0, 1, 0, 2]
	])

	watch_signals(data)
	data.fill_empty()

	assert_signal_emit_count(data, 'filled', 3)
	assert_signal_emitted_with_parameters(data, 'filled', [Vector2i(2, 0)], 2)
	assert_signal_emitted_with_parameters(data, 'filled', [Vector2i(2, 1)], 1)
	assert_signal_emitted_with_parameters(data, 'filled', [Vector2i(2, 2)], 0)

	assert_eq_deep(data._data, [
		[1, 1, 1, 0],
		[0, 1, 2, 0],
		[0, 0, 2, 1],
		[0, 1, 0, 2]
	])

	for x in data._data:
		print(x)


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
	assert_signal_emitted_with_parameters(data, 'moved', [Vector2i(0, 3), Vector2i(0, 0)])

	assert_signal_emit_count(data, 'filled', 3)
	assert_signal_emitted_with_parameters(data, 'filled', [Vector2i(0, 0)], 2)
	assert_signal_emitted_with_parameters(data, 'filled', [Vector2i(0, 1)], 1)
	assert_signal_emitted_with_parameters(data, 'filled', [Vector2i(0, 2)], 0)

	assert_eq_deep(data._data, [
		[1, 2, 1, 0],
		[0, 1, 2, 0],
		[0, 2, 1, 1],
		[1, 1, 0, 2]
	])

func test_swap_and_collapse_horizontal():
	var data = _create([
		[3, 2, 1, 2],
		[0, 3, 2, 3],
		[2, 2, 3, 1],
		[1, 0, 0, 2]
	])

	watch_signals(data)
	data.swap(Vector2(2, 1), Vector2(2, 2))

	assert_signal_emit_count(data, 'matched', 1)
	assert_signal_emitted_with_parameters(data, 'matched', [ Vector2i(2, 2), Vector2i(1, 2), Vector2i(0, 2)])

	# assert_signal_emit_count(data, 'filled', 3)
	# assert_signal_emitted_with_parameters(data, 'filled', [Vector2i(0, 0)], 2)
	# assert_signal_emitted_with_parameters(data, 'filled', [Vector2i(0, 1)], 1)
	# assert_signal_emitted_with_parameters(data, 'filled', [Vector2i(0, 2)], 0)

	# assert_eq_deep(data._data, [
	# 	[0, 0, 0, 2],
	# 	[3, 2, 1, 3],
	# 	[0, 3, 3, 1],
	# 	[1, 0, 0, 2]
	# ])

	# for x in data._data:
	# 	print(x)
