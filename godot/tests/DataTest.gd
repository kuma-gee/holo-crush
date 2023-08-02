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
			if not j in values:
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


func test_move_not_match():
	var data = _create([
		[1, 2, 1, 0],
		[0, 1, 2, 0],
		[0, 2, 1, 1],
		[1, 0, 0, 2]
	])

	data.move(Vector2(0, 0), Vector2(1, 0))

	assert_eq_deep(data._data, [
		[1, 2, 1, 0],
		[0, 1, 2, 0],
		[0, 2, 1, 1],
		[1, 0, 0, 2]
	])


func test_move_and_collapse_vertical():
	var data = _create([
		[1, 2, 1, 0],
		[0, 1, 2, 0],
		[0, 2, 1, 1],
		[1, 0, 0, 2]
	])

	data.move(Vector2(1, 3), Vector2(0, 3))

	assert_eq_deep(data._data, [
		[1, 2, 1, 0],
		[0, 1, 2, 0],
		[0, 2, 1, 1],
		[1, 1, 0, 2]
	])

	for x in data._data:
		print(x)


func test_move_and_collapse_horizontal():
	var data = _create([
		[1, 2, 1, 0],
		[0, 1, 2, 0],
		[2, 2, 1, 1],
		[1, 0, 0, 2]
	])

	data.move(Vector2(1, 1), Vector2(1, 0))

	assert_eq_deep(data._data, [
		[0, 0, 1, 0],
		[0, 2, 2, 0],
		[2, 2, 1, 1],
		[1, 0, 0, 2]
	])