# Rematch - Tài Liệu Kỹ Thuật

## Tổng quan
Rematch là một trò chơi hành động góc nhìn thứ ba 3D được phát triển bằng Godot 4.6 (chế độ GL Compatibility). Dự án bao gồm nhân vật người chơi với hệ thống di chuyển nâng cao, hòa trộn hoạt ảnh (animation blending) và hệ thống kỹ năng bàn cờ độc đáo. Trò chơi hiện đang trong giai đoạn phát triển sớm với các hệ thống di chuyển cốt lõi đã được hoàn thiện và cấu trúc có khả năng mở rộng cho AI, chiến đấu và hệ thống menu.

**Cảnh thử nghiệm (Test Scene):** `scenes/Maps/Test_world.tscn`  
**Phiên bản Project:** Godot 4.6  
**Ngôn ngữ chính:** GDScript

## Cấu trúc dự án

```
rematch/
├── addons/
│   └── terrain_3d/          # Plugin Terrain3D để tạo địa hình
├── scripts/
│   └── Player_control/      # Cơ chế người chơi cốt lõi (di chuyển, camera, kỹ năng)
├── scenes/
│   ├── Maps/                # Cảnh cấp độ (IntroWorld.tscn, Test_world.tscn)
│   └── Menu/                # Hệ thống menu (Main_menu.tscn)
├── models/
│   └── characters/player/   # Tài nguyên và hoạt ảnh nhân vật người chơi
├── entities/
│   └── test_enemy/          # Thực thể kẻ thù (Test_dummy.tscn)
├── materials/
│   └── Shader/              # Shader tùy chỉnh (Chesstiles.gdshader)
├── textures/                # Tài nguyên texture
├── terrain/                 # Tài nguyên địa hình cụ thể
├── ai/                      # Hệ thống AI (hiện tại trống)
├── audio/                   # Tài nguyên âm thanh (hiện tại trống)
├── main/                    # Logic trò chơi chính (hiện tại trống)
└── resources/               # Tài nguyên trò chơi (hiện tại trống)
```

**Tổ chức thư mục theo mã màu:**
- 🟦 Xanh dương: scripts/
- 🟩 Xanh lá: main/, scenes/
- 🟨 Vàng: materials/, models/, textures/
- 🟧 Cam: resources/
- 🟦 Xanh lơ: entities/

## Hệ thống cốt lõi

### Hệ thống điều khiển người chơi (Player Control System)

#### Di chuyển & Hoạt ảnh (`scripts/Player_control/player_loco.gd`)
- **Lớp cơ sở (Base Class):** `CharacterBody3D`
- **Tính năng di chuyển:**
  - Hòa trộn Đi bộ/Chạy với hệ số tốc độ 1.5x (phím Shift).
  - Hòa trộn hoạt ảnh 8 hướng (tiến, lùi, di chuyển ngang trái/phải).
  - Cơ chế nhảy với vận tốc có thể cấu hình (4.5 đơn vị).
  - Hệ thống trọng lực với bộ đệm rơi (ngưỡng 0.3 giây) để ngăn lỗi nháy hoạt ảnh.
  - Di chuyển tương đối theo Camera (hướng tiến luôn là "hướng ra xa camera").

- **Hệ thống hoạt ảnh:**
  - AnimationTree với State Machine và 2D Blend Spaces.
  - Trạng thái đi bộ (Walk): 5 hoạt ảnh (nghỉ + 4 hướng).
  - Trạng thái chạy (Run): 4 hoạt ảnh hướng.
  - Trạng thái Nhảy/Rơi (Jump/Fall) với chuyển tiếp chồng mờ (cross-fade).
  - Điều chỉnh FOV động: 75° (đi bộ) → 85° (chạy).

- **Các tham số chính:**
  ```gdscript
  @export_group("Movement Settings")
  @export var default_speed: float = 5.0
  @export var run_multiplier: float = 1.5
  @export var jump_velocity: float = 4.5
  @export var rotation_speed: float = 10.0


#### Hệ thống Camera (`scripts/Player_control/CameraControl.gd`)
- **Kiến trúc**: CameraPivot (ngang) → SpringArm3D (dọc) → Camera3D.
- **Điều khiển**: Di chuyển chuột với khả năng lia mượt mà (độ nhạy: 0.0015).
- **Phạm vi nhìn dọc**: -70° (xuống) đến +30° (lên).
- **Độ dài Spring Arm**: 3.0 đơn vị.
- **Tính năng**: Nhấn ESC để bật/tắt khóa chuột, vùng phát hiện Area3D cho các tương tác.(sẽ được thay đổi để mở menu trong tương lai)

#### Tính năng Bàn cờ (`scripts/Player_control/Playerskill.gd`)
- **Lớp**: MultiMeshInstance3D
- **Cơ chế**: Tạo lưới bàn cờ N×N khi được kích hoạt gần các vùng tương tác.
- **Hiệu ứng hình ảnh**: Các ô trắng/đen xen kẽ với hiệu ứng shader.
- **Kích hoạt**: Phím Q (chỉ mở khi khi có vật thể vào vùng Area3D).

### Va chạm & Vật lý (Collision & Physics)

| Layer | Name | Mục đích | Mask |
|-------|------|---------|------|
| 1 | World/Static | Mặt đất, vật cản, obstacles | None |
| 2 | Player |  Người chơi | 1, 4 (World + Interactions) |
| 3 | Enemy | Kẻ thù | 1, 2 (World + Player) |
| 4 | Area3D | Vùng tương tác | 3 (Kẻ thù) |

### Shaders & Materials

#### Chess Tiles Shader (`materials/Shader/Chesstiles.gdshader`)
```glsl
shader_type spatial;
uniform float speed = 2.0;
uniform float strength = 0.5;

void vertex() {
    VERTEX.y += sin(TIME * speed) * strength;
}
```

## Scene Hierarchy

### Test_world.tscn (Test Game Scene)
```
TestWorld [Node3D]
├── WorldEnvironment
├── DirectionalLight3D 
├── plane [ mặt đất ]
├── cube
├── Player_loco [Nhân vật người chơi]
│   ├── Armature [nhân vật + animatin]
│   ├── CollisionShape3D [va chạm]
│   ├── AnimationTree [Statemachine Animation]
│   ├── CameraPivot [Hệ thống camera]
│   └── ChessboardDeploy [Hiệu ứng kỹ năng]
└── TestDummy [Kẻ thù ]
    ├── MeshInstance3D [màu đỏ]
    └── CollisionShape3D [va chạm]
```

### Player_loco.tscn (Player Prefab)
- CharacterBody3D với Skeleton3D có rigging
- AnimationTree cho di chuyển hòa trộn
- Hệ thống camera với spring arm
- MultiMeshInstance3D cho kỹ năng bàn cờ

## Coding Standards & Patterns

### Node References
- Dùng `@onready` Cho mọi code cần path phần ngoài:
```gdscript
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
```

### Inspector Organization
- Group related properties with `@export_group`:
```gdscript
@export_group("Movement Settings")
@export_subgroup("Speed")
@export var default_speed: float = 5.0
```

### Code Organization
- Use regions for large code blocks:
```gdscript
#region Movement Logic
func _handle_movement(delta: float):
    # Code di chuyển ở đây
    pass
#endregion
```

## Getting Started

1. **Yêu cầu tiên quyết:** Godot 4.6 
2. **Mở dự án:** Mở `project.godot` trong Godot Editor
3. **Chạy cảnh chính:** `scenes/Maps/Test_world.tscn`
4. **Điều khiển:**
   - WASD: Di chuyển
   - Chuột: Nhìn camera
   - Shift: Chạy
   - Space: Nhảy
   - Q: Kỹ năng bàn cờ (khi trong phạm vi)
   - ESC: Bật/tắt bắt chuột

## Luật viết code

- **Tuân thủ các mẫu hiện có:** Sử dụng `@onready`, `@export_group`, và comment vùng
- **Thiết kế mô-đun:** Giữ các chức năng tách biệt (di chuyển, camera, kỹ năng)
- **Tham số hóa:** Làm cho các biến có thể cấu hình qua `@export`
- **Tài liệu:** Thêm comment cho logic phức tạp
- **Kiểm thử:** Xác minh tương tác va chạm và trạng thái hoạt ảnh

## Technical Notes

- **Armature Forward:** Hướng -Z (mũi tên xanh Godot)
- **Hướng di chuyển:** Tương đối theo camera, không phải hướng nhân vật
- **Hòa trộn hoạt ảnh:** Trục Y bị đảo ngược trong không gian blend (tiến = -1)
- **Tối ưu hóa MultiMesh:** Được sử dụng để render bàn cờ hiệu quả
- **Bộ đệm rơi:** Ngăn nháy hoạt ảnh trên các cạnh nhỏ
- **Sử dụng Shader:** Shader không gian cho hiệu ứng 3D, shader canvas cho UI