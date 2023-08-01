extends UnitTest

func before_each():
	seed(0)

func _create(width: int, height: int) -> Data:
	var data = autofree(Data.new())
	data.width = width
	data.height = height
	return data
	

func test_matches():
	var data = _create(4, 4)
	data.set_data([
		[1, 1, 1, 0],
		[0, 1, 2, 0],
		[0, 2, 1, 1],
		[0, 1, 0, 2]
	] as Array[Array])
	
	assert_eq_deep(data.get_matches(0, 0), [])
	assert_eq_deep(data.get_matches(1, 0), [])
	assert_contains_exact(data.get_matches(2, 0), [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)])

	assert_eq_deep(data.get_matches(0, 1), [])
	assert_eq_deep(data.get_matches(0, 2), [])
	assert_contains_exact(data.get_matches(0, 3), [Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)])
