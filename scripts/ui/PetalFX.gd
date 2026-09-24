extends CanvasLayer
## PetalFX - lớp hoa bay phủ màn hình (screen-space), nhẹ, không ảnh hưởng gameplay.
## Đặt layer thấp để nằm sau UI nhưng trước cảnh? -> thực ra để trước cảnh cho thấy hoa
## rơi phía trước. layer = 5 (trên map, dưới TouchControls layer 10).

func _ready() -> void:
	layer = 5
