# Bubu Dudu Adventure

Game 2D side-scrolling khám phá cho Android, xây bằng **Godot 4.3 + GDScript**.

## Ý tưởng

Người chơi bắt đầu trong **nhà** (lưu game, cất đồ, chế tạo), ra **Phố Cổ Hoa Lư**
(khu phố cổ ven sông, trò chuyện với dân làng), rồi vào **Rừng** để khám phá
(chặt cây lấy gỗ, đào khoáng, săn thú), làm **nhiệm vụ** để mở map mới.

Luồng khởi động: **Splash → Menu chính → Intro cutscene → Tutorial → Gameplay**.

Bản đồ nối tiếp: **Nhà → Phố Cổ Hoa Lư → Rừng → (Bờ biển - mở khóa qua quest)**.

## Bản đồ

| Map | File | Nội dung |
|-----|------|----------|
| Nhà | `House.tscn` | Lưu game (giường), rương, bàn chế tạo. Cửa ra Phố Cổ Hoa Lư. |
| Phố Cổ Hoa Lư | `PhoCoHoaLu.tscn` | Khu phố cổ ven sông (parallax). **Chỉ có NPC để trò chuyện**, không quái/cây. Cổng trái về Nhà, cổng phải vào Rừng. |
| Rừng | `Rung.tscn` | Khu khám phá: cây/đá/quặng để thu thập + thú để săn + nhiệm vụ. Cổng trái về phố cổ, cổng phải tới Bờ biển (khóa). |
| Bờ biển | `Beach.tscn` | Map stub, mở khóa khi hoàn thành quest gom gỗ. |

## Hệ thống hội thoại NPC

- `NPC` (`scripts/actors/NPC.gd`, extends `Interactable`): `@export npc_name` + `lines: Array[String]`.
- `DialogueUI` (`scenes/ui/DialogueUI.tscn`, group `dialogue_ui`): hộp thoại dưới màn hình,
  chạm/nút "Tiếp"/phím Tương tác để qua câu, hết thì đóng. Khóa input gameplay khi mở
  (`PlayerInput.input_locked`).
- Phố Cổ Hoa Lư có 5 NPC (Cụ Lang Già, Chị Bán Hàng, Bác Ngư Dân, Cu Tí, Thầy Đồ) với
  thoại mặc định — chỉnh lại text ngay trong `PhoCoHoaLu.tscn` (thuộc tính `lines` của mỗi NPC).

## Tech stack & quyết định thiết kế

- **Engine**: Godot 4.3, GL Compatibility renderer (nhẹ, chạy tốt máy Android yếu).
- **Góc nhìn**: Side-scrolling (kiểu Terraria), nhảy/leo.
- **Map**: Rời rạc, có màn hình loading khi chuyển, layout thiết kế tay cố định.
- **Khai thác**: Địa hình tĩnh, tài nguyên đặt sẵn tự hồi sinh sau timer.
- **Chiến đấu**: Cận chiến (kiếm/rìu) + tầm xa (cung/súng).
- **Điều khiển**: Joystick ảo (trái) + nút hành động (phải) cho cảm ứng; bàn phím để test trên desktop.
- **Inventory**: Theo ô có giới hạn + rương lưu trữ; lưu game khi ngủ hoặc thủ công.

## Cấu trúc thư mục

```
scenes/
  actors/     # Player, Enemy, ... (PackedScene)
  boot/       # SplashScreen, MainMenu, IntroCutscene
  maps/       # House, PhoCoHoaLu, Rung, Beach
  test/       # TestRoom - scene test tạm cho Task 1
  ui/         # HUD, Inventory UI, ... (thêm dần)
scripts/
  autoload/   # GameState, PlayerInput, SceneManager (singleton)
  actors/     # Logic nhân vật
  systems/    # Inventory, Quest, Save ... (thêm dần)
data/         # ItemData, RecipeData, QuestData (.tres) (thêm dần)
assets/       # Sprite, tileset (free Kenney/itch.io - thêm dần)
```

## Chạy & test

Mở project bằng Godot 4.3+ (`project.godot`).

- **Task 1 hiện tại**: main scene là `scenes/test/TestRoom.tscn`.
  - Desktop: `A`/`D` hoặc phím mũi tên để di chuyển, `Space` để nhảy.
  - Sẽ đổi main scene sang `SplashScreen` khi làm Task 3.

## Input Actions

| Action            | Phím (desktop) |
|-------------------|----------------|
| move_left         | A / ←          |
| move_right        | D / →          |
| jump              | Space / ↑      |
| attack            | J              |
| ranged_attack     | K              |
| interact          | E              |
| toggle_inventory  | I              |

## Điều khiển cảm ứng (Task 2)

- **Joystick ảo** góc dưới trái: kéo để di chuyển ngang.
- **Nút phải**: Nhảy, Đánh (cận chiến), Bắn (tầm xa), Tương tác.
- Cảm ứng được nối vào `PlayerInput` nên logic gameplay không phụ thuộc nguồn input.
- Trên desktop có bật `emulate_touch_from_mouse` để test joystick bằng chuột.
- Scene tái sử dụng: `scenes/ui/TouchControls.tscn` (thêm vào bất kỳ map gameplay nào).

## Trạng thái tiến độ

Xem task list trong session. Đã xong:
- **Task 1**: khởi tạo project + player di chuyển/nhảy.
- **Task 2**: điều khiển cảm ứng (joystick + nút) + cấu hình export Android.
- **Task 3**: Splash → Menu chính (New Game/Continue/Settings/Quit) + SceneManager (fade transition). Main scene giờ là `SplashScreen.tscn`.
- **Task 4**: Scene Nhà (`scenes/maps/House.tscn`) với nền/tường, camera giới hạn, và đồ tương tác (Giường/Rương/Bàn chế tạo/Cửa ra). Hệ tương tác: `Interactable` base + prompt hiện khi lại gần, nút Tương tác kích hoạt cái gần nhất. New Game giờ vào thẳng Nhà.
- **Task 5**: Inventory theo ô (data-driven). `ItemData` (.tres), `ItemDB` autoload tra cứu theo id, `Inventory` class (add/remove/stack), `PlayerInventory` autoload, UI túi đồ lưới ô (phím `I` hoặc nút "Túi"). Item: gỗ/đá/quặng/sợi + rìu/cuốc/kiếm/cung. (Tạm: mở Rương cho item mẫu để test, Task 9 thay bằng UI rương thật.)
- **Task 6**: Map Rừng ngoài trời (`scenes/maps/Forest.tscn`, rộng 2400px) + chuyển map hai chiều Nhà↔Rừng qua cổng, có màn hình loading (fade) và spawn point. `SceneManager.goto_map` free scene cũ khi đổi map.

## Cảnh nền phố cổ (parallax)

Map Rừng dùng nền tranh phố cổ ven sông từ các package "Meowa" (`assets/`), ghép 3 lớp
qua `ParallaxBackground` để có hiệu ứng chiều sâu khi di chuyển:

| Lớp | Ảnh (1376×768) | `motion_scale` | Vai trò |
|-----|----------------|----------------|---------|
| Sky | `sky-4/.../image-4.png` | 0.20 | Bầu trời + núi xa (cuộn chậm nhất) |
| Town | `background-godot4/.../background.png` | 0.55 | Nhà cổ, đèn lồng, cầu, sông, thuyền |
| Street | `street-3/.../image-3.png` | 1.00 | Đường lát đá nơi nhân vật đi (world-locked) |

Mỗi lớp bật `motion_mirroring.x = 1376` để **lặp ngang liền mạch** phủ hết map 2400px.
Collision mặt đất giữ nguyên (`StaticBody2D`), art đường chỉ là hình nền phía sau nhân vật.
Đã bỏ các platform/đồi placeholder cũ để khớp mặt đường phẳng.

### Layer bổ sung ở Phố Cổ Hoa Lư

- **Tháp** (`assets/thap.png`): ParallaxLayer `motion_scale=0.42` (giữa sky và town), đặt sau
  layer town làm điểm nhấn đường chân trời.
- **Cổng "Phố Cổ Hoa Lư"** (`assets/gate.png`): `Sprite2D` world-locked ở giữa map
  (`z_index=5`, trên nhân vật) để player đi xuyên qua khung cổng.
- Cả 2 ảnh gốc là JPG nền trắng → đã khử nền trắng thành PNG trong suốt (bằng Godot Image API,
  ngưỡng độ trắng + độ bão hòa + feather mép) để hòa vào cảnh.

### Hiệu ứng

- **Hoa bay** (`scenes/ui/PetalFX.tscn`): `CPUParticles2D` phủ màn hình (CanvasLayer),
  cánh hoa hồng rơi + xoay + đung đưa. Texture `assets/fx/petal.png`.
- **Mây trôi** (`scripts/actors/CloudDrift.gd`): vài `Sprite2D` mây trong SkyLayer trôi ngang
  chậm rồi vòng lại. Texture `assets/fx/cloud.png`.
- Texture hoa/mây sinh bằng `tools/gen_petal.py` (Python thuần, không lib ngoài).
- **Task 7**: Tài nguyên khai thác. `ResourceNode` (cây→gỗ, đá→đá, quặng→quặng) có HP, rơi item vào túi, ẩn đi và hồi sinh sau timer. Player có hitbox tấn công theo hướng (nút "Đánh"/phím J); công cụ phù hợp (rìu/cuốc) trong túi tăng lực khai thác. Rừng có sẵn 3 cây + 1 đá + 1 quặng.
- **Task 8**: Chiến đấu. `Enemy` AI patrol/chase/attack với máu (thanh HP đầu quái), rơi sợi khi chết. Cận chiến dùng kiếm (nút "Đánh"), tầm xa bắn tên bằng cung (nút "Bắn"/phím K, cần có cung trong túi). Player có máu (thanh HUD), nhận sát thương khi quái đánh, bất tử tạm sau khi trúng, chết thì hồi sinh về nhà. `HealthComponent`/`Hurtbox` tái sử dụng. Rừng có 3 quái.
- **Task 9**: Rương + Chế tạo. Rương (`ChestUI`) chuyển đồ túi↔rương (chạm ô để chuyển stack), nội dung giữ trong `ChestStorage` autoload. Bàn chế tạo (`CraftingUI`) hiển thị công thức từ `RecipeData` (.tres), nút Chế tạo bật khi đủ liệu, craft trừ nguyên liệu + thêm sản phẩm. Recipe: gỗ→rìu, gỗ+đá→cuốc, gỗ+quặng→kiếm, gỗ+sợi→cung. (Đã gỡ code cấp item test ở Rương.)
- **Task 10**: Nhiệm vụ data-driven. `QuestData` (.tres) + `QuestManager` autoload theo dõi tiến độ (thu thập item / hạ thú). UI quest góc phải. Hoàn thành quest mở khóa map mới: gom 10 gỗ → mở khóa **Bờ biển** (`Beach.tscn` stub), cổng phải trong rừng bị khóa cho tới khi xong quest. Quest 2: hạ 3 thú.
- **Task 11**: Intro cutscene (`scenes/boot/IntroCutscene.tscn`). Chuỗi slide cốt truyện có fade, chạm để qua slide, nút Bỏ qua. New Game → Intro → (Nhà). Luồng: Splash → Menu → New Game → Intro → gameplay.
- **Task 12**: Tutorial (`TutorialOverlay` trong Nhà). Dạy di chuyển → nhảy → mở túi theo bước, phát hiện qua trạng thái nhân vật (không cướp input), có nút Bỏ qua. Chạy 1 lần (cờ `tutorial_done`). Luồng đầy đủ: Splash → Menu → New Game → Intro → Nhà (Tutorial) → tự do chơi.
- **Task 13**: Save/Load. `SaveManager` autoload ghi/đọc JSON `user://savegame.json` (gom GameState + túi + rương + quest + trạng thái tài nguyên đã khai thác). Ngủ trên giường = lưu game + hồi đầy máu; nút "Lưu" trên HUD để lưu thủ công. Menu **Chơi tiếp** bật khi có save, nạp và vào thẳng map đã lưu (bỏ qua intro/tutorial). Tài nguyên đã khai thác được khôi phục đúng theo map.

## Vòng lặp gameplay hoàn chỉnh (MVP)

1. Mở game → Splash → Menu chính.
2. **Chơi mới** → Intro cốt truyện → vào Nhà, chạy tutorial hướng dẫn.
3. Ra cửa → Rừng: chặt cây lấy gỗ (tay không cũng được, có rìu thì nhanh hơn), đào đá/quặng, săn thú.
4. Về Nhà: cất đồ vào rương, chế tạo rìu/cuốc/kiếm/cung tại bàn chế tạo.
5. Làm nhiệm vụ (gom 10 gỗ) để mở khóa map **Bờ biển**.
6. Ngủ trên giường hoặc nhấn "Lưu" để lưu game.
7. Tắt game, mở lại → **Chơi tiếp** khôi phục đúng trạng thái.

## Build APK Android

Xem hướng dẫn chi tiết: [`docs/ANDROID_EXPORT.md`](docs/ANDROID_EXPORT.md).
Preset **Android** đã được cấu hình sẵn trong `export_presets.cfg` (offline, landscape,
armeabi-v7a + arm64-v8a). Chỉ cần:
1. Cài **Android export templates** cho phiên bản Godot của bạn (Editor → Manage Export Templates).
2. Trỏ Godot tới **Android SDK + debug keystore** (Editor Settings → Export → Android).
3. Export ra `build/BubuDuduAdventure.apk`.

Preset đã được kiểm tra hợp lệ (Godot chỉ báo thiếu export templates — bước cài ở trên).

## Trạng thái kiểm thử

Dự án đã được **import và chạy thử bằng Godot** (headless):
- Tất cả script biên dịch không lỗi parse.
- Các scene (Splash, Menu, Intro, Nhà, Rừng, Bờ biển) load & chạy không lỗi runtime.
- Save/Load đã test tự động: túi đồ, rương, máu, map hiện tại, spawn, map đã mở khóa,
  tài nguyên đã khai thác, và tiến độ quest đều khôi phục đúng sau save → xóa RAM → load.
