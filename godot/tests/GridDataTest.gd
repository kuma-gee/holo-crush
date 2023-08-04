extends UnitTest

func before_each():
	Debug.log_level = Debug.Level.INFO
	seed(100)

func _create(initial_data: Array) -> GridData:
	return GridData.new(-1, -1, initial_data)

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
	
	assert_contains_exact(data.get_matches(2, 2), [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(2, 2), Vector2i(2, 1), Vector2i(2, 0)])

func test_match_counts():
	var data = _create([
		[1, 1, 0, 1],
		[2, 1, 0, 2],
		[0, 0, 0, 1],
		[3, 1, 2, 2]
	])

	var counts = data.get_match_counts()
	assert_contains_exact(counts.keys(), [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(2, 1), Vector2i(2, 0)])
	assert_eq(counts[Vector2i(0, 2)], 1)
	assert_eq(counts[Vector2i(1, 2)], 1)
	assert_eq(counts[Vector2i(2, 2)], 2)
	assert_eq(counts[Vector2i(2, 1)], 1)
	assert_eq(counts[Vector2i(2, 0)], 1)

func test_swap():
	var data = _create([
		[1, 1, 2],
		[2, 1, 0],
		[0, 0, 1],
	])
	data.swap_value(Vector2i(0, 0), Vector2i(0, 1))

	assert_eq(data.get_value(0, 0), 2);
	assert_eq(data.get_value(0, 1), 1);

func test_not_swap_outside():
	var data = _create([
		[1, 1, 2],
		[2, 1, 0],
		[0, 0, 1],
	])
	data.swap_value(Vector2i(0, 0), Vector2i(0, -1))

	assert_eq(data.get_value(0, 0), 1);
	assert_eq(data.get_value(0, 1), 2);


func test_duplicate():
	var data = _create([
		[1, 1, 2],
		[2, 1, 0],
		[0, 0, 1],
	])

	var clone = data.duplicate()
	clone.swap_value(Vector2i(0, 0), Vector2i(0, 1))

	assert_eq(data.get_value(0, 0), 1);
	assert_eq(data.get_value(0, 1), 2);

	
func test_refill():
	var data = _create([
		[1, 1, 1, 0],
		[0, 1, 2, 0],
		[0, 2, 1, 1],
		[0, 1, 0, 2]
	])

	for _i in range(10):
		data.refill()
		assert_eq(data.get_match_counts().size(), 0, "Contains no matches")
		assert_ne_deep(data.get_data(), [
			[1, 1, 1, 0],
			[0, 1, 2, 0],
			[0, 2, 1, 1],
			[0, 1, 0, 2]
		])