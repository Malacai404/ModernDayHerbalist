@tool
extends VoxelGI

func _ready() -> void:
	if not Engine.is_editor_hint():
		# Force re-apply the baked data at runtime
		var data = get_probe_data()
		if data:
			set_probe_data(null)   # Clear first
			set_probe_data(data)   # Re-set it
