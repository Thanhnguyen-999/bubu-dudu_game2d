# Hướng dẫn export APK Android

Godot không được cài trên máy build tự động, nên các bước dưới đây cần làm **một
lần** trong Godot editor trên máy của bạn. Sau khi cấu hình xong, mỗi lần export
chỉ là 1 cú click.

## 1. Cài công cụ nền (một lần)

1. **JDK 17** (OpenJDK). Kiểm tra: `java -version`.
2. **Android SDK** — cách dễ nhất: cài **Android Studio**, mở SDK Manager và cài:
   - Android SDK Platform-Tools
   - Android SDK Build-Tools
   - NDK (Side by side) — chỉ cần nếu dùng Gradle build
   - Command-line Tools

## 2. Trỏ Godot tới Android SDK

Trong Godot: **Editor → Editor Settings → Export → Android**
- **Java SDK Path**: thư mục JDK 17
- **Android SDK Path**: thư mục Android SDK (VD: `C:\Users\<user>\AppData\Local\Android\Sdk`)

Godot sẽ báo dấu ✓ xanh khi nhận đúng đường dẫn.

## 3. Tạo debug keystore (một lần)

Godot 4 có thể tự tạo debug keystore. Nếu chưa có, chạy lệnh (cần JDK):

```powershell
keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android `
  -keystore debug.keystore -storepass android `
  -dname "CN=Android Debug,O=Android,C=US" -validity 9999 -deststoretype pkcs12
```

Rồi trong **Editor Settings → Export → Android**, đặt **Debug Keystore** trỏ tới
file `debug.keystore` vừa tạo (keystore user / password `android`).

## 4. Cài Android Build Template

Trong Godot: **Project → Install Android Build Template...**
(chỉ cần nếu bật `Use Gradle Build` trong preset — preset hiện tại đang để
`use_gradle_build=false` nên dùng template APK dựng sẵn, KHÔNG cần bước này).

Nếu muốn tùy biến sâu (icon, permission, plugin) thì bật Gradle build và cài template.

## 5. Export

1. **Project → Export...**
2. Chọn preset **Android** (đã có sẵn trong `export_presets.cfg`).
3. Bấm **Export Project** → lưu ra `build/BubuDuduAdventure.apk`.
   - Hoặc bấm **Export Project** với "Debug" để cài nhanh lên máy test.

## 6. Cài lên điện thoại

```powershell
adb install -r build/BubuDuduAdventure.apk
```

(Bật **USB debugging** trên điện thoại, cắm cáp, chấp nhận uỷ quyền.)

## Ghi chú preset hiện tại

- `package/unique_name = com.bubududu.adventure`
- Kiến trúc: `armeabi-v7a` + `arm64-v8a` (phủ hầu hết máy Android).
- `permissions/internet = false` (game offline hoàn toàn — nhẹ và an toàn).
- `screen/immersive_mode = true` (ẩn thanh hệ thống khi chơi).
- Orientation: **landscape** (đặt trong `project.godot`).
