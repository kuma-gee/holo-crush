class_name SpecialMark
extends ColorRect

func for_slot(slot: Slot, s: Vector2):
	size = s * slot.size
	pivot_offset = size / 2
	position = slot.get_pos()
