# Rematch - Tài Liệu Kỹ Thuật

## Tổng quan
Rematch là một trò chơi chiến thuật góc nhìn thứ ba 3D được phát triển bằng Godot 4.6. Dự án bao gồm nhân vật người chơi với hệ thống di chuyển và hệ thống kỹ năng bàn cờ độc đáo.

**Cảnh thử nghiệm (Test Scene):** `scenes/Maps/Test_world.tscn`  
**Phiên bản Project:** Godot 4.6  
**Ngôn ngữ chính:** GDScript

## Cấu trúc dự án

```
rematch/
├── addons/
│   └── terrain_3d/          # Plugin Terrain3D để tạo địa hình
├── scripts/
│   └── Player_control/      # Core player script (di chuyển, camera, kỹ năng)
├── scenes/
│   ├── Maps/                # Scenes (IntroWorld.tscn, Test_world.tscn)
│   └── Menu/                # Hệ thống menu (Main_menu.tscn)
├── models/
│   └── characters/player/   # Tài nguyên và hoạt ảnh nhân vật người chơi
├── entities/
│   └── test_enemy/          # thực thể
├── materials/
│   └── Shader/              # Shader (Chesstiles.gdshader)
├── textures/
├── terrain/                 # Height map được lưu dưới dạng binary
├── ai/                      # Hệ thống AI
├── audio/                   # Tài nguyên âm thanh
├── main/                    # Logic trò chơi chính
└── resources/               # Tài nguyên trò chơi
```

## Hệ thống cốt lõi

### Hệ thống điều khiển người chơi (Player Control System)

#### Di chuyển & Animation (`scripts/Player_control/player_loco.gd`)
- **Lớp cơ sở (Base Class):** `CharacterBody3D`
- **Tính năng di chuyển:**
  - Blend Đi bộ/Chạy với hệ số tốc độ (phím Shift).
  - Blend hoạt ảnh 8 hướng (tiến, lùi, di chuyển ngang trái/phải).
  - Cơ chế nhảy với vận tốc có thể cấu hình.
  - Hệ thống trọng lực với bộ đệm rơi (ngưỡng 0.3 giây) để ngăn lỗi nháy animation.
  - Di chuyển tương đối theo Camera (hướng tiến luôn là "hướng đối diện camera basis").

- **Hệ thống Animations:**
  - AnimationTree với State Machine và 2D Blend Spaces.
  - Trạng thái đi bộ (Walk): 5 hoạt ảnh (nghỉ + 4 hướng).
  - Trạng thái chạy (Run): 4 hoạt ảnh hướng.
  - Trạng thái Nhảy/Rơi (Jump/Fall) với chuyển tiếp cross-fade.
  - Điều chỉnh FOV động: 75° (đi bộ) → 85° (chạy).

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
- AnimationTree cho blend di chuyển
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

## Technical Notes

- **Armature Forward:** Hướng -Z (mũi tên xanh Godot)
- **Blend animation:** Trục Y bị đảo ngược trong không gian blend (tiến = -1)
