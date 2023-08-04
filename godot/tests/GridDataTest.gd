extends UnitTest

func _create(initial_data: Array) -> GridData:
	return GridData.new(initial_data[0].size(), initial_data.size(), initial_data)

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
