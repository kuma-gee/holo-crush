class_name UnitTest
extends GutTest

func assert_contains_exact(arr: Array, items: Array):
	assert_eq(arr.size(), items.size())
	assert_contains_all(arr, items)

func assert_contains_all(arr: Array, items: Array):
	for i in items:
		assert_has(arr, i)

# Only one parameter supported
func assert_signal_emitted_in_any_order(data, signal_name, params):
	var flatten = []
	for x in get_all_signal_parameters(data, signal_name):
		flatten.append_array(x)
	
	assert_contains_all(flatten, params)

func get_all_signal_parameters(data, signal_name):
	var all_params = []
	for i in get_signal_emit_count(data, signal_name):
		all_params.append(get_signal_parameters(data, signal_name, i));
	return all_params
