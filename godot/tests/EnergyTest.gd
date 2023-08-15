extends UnitTest

var energy: Energy

func before_each():
    energy = Energy.new()
    energy.max_energy = 5
    add_child_autofree(energy)

func test_restore_energy():
    energy.restore_minutes = 5

    energy.use_energy(DateTime.new('2020-01-01T00:00:00Z'))
    assert_eq(energy.energy, 4)

    energy.restore(DateTime.new('2020-01-01T00:04:00Z'))
    assert_eq(energy.energy, 4)

    energy.restore(DateTime.new('2020-01-01T00:05:00Z'))
    assert_eq(energy.energy, 5)

func test_restore_multiple_energy():
    energy.restore_minutes = 5

    energy.use_energy(DateTime.new('2020-01-01T00:00:00Z'))
    energy.use_energy(DateTime.new('2020-01-01T00:01:00Z'))
    energy.use_energy(DateTime.new('2020-01-01T00:02:00Z'))
    energy.use_energy(DateTime.new('2020-01-01T00:03:00Z'))
    assert_eq(energy.energy, 1)


    energy.restore(DateTime.new('2020-01-01T00:12:00Z'))
    assert_eq(energy.energy, 3)

    energy.restore(DateTime.new('2020-01-01T00:16:00Z'))
    assert_eq(energy.energy, 4)

    energy.restore(DateTime.new('2020-01-01T00:19:00Z'))
    assert_eq(energy.energy, 4)

    energy.restore(DateTime.new('2020-01-01T00:20:00Z'))
    assert_eq(energy.energy, 5)

    energy.restore(DateTime.new('2020-01-01T00:30:00Z'))
    assert_eq(energy.energy, 5)