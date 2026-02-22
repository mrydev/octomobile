# 🐙 OctoMobile

![OctoMobile Header](assets/images/readme_header.png)

**OctoMobile** is a premium, open-source Flutter application designed for seamless monitoring and management of your OctoPrint-powered 3D printers. Experience full control of your workshop from your pocket with a modern, high-performance interface.

---

## ✨ Key Features

### 🚀 Real-time Monitoring & Control
- **Smart Dashboard**: Instant access to print progress (with precise radial UI indicators), time remaining, and system status upon app launch.
- **Glassmorphic Aesthetics**: A highly refined UI focused on modern dark themes, rounded corners, and soft data visualizations.
- **Temperature Control**: Precise monitoring and control for both Hotend and Heatbed using animated gauges.
- **Webcam Integration**: High-frequency MJPEG stream support for visual monitoring with fullscreen rotation support.
- **Print Actions**: Effortlessly pause, resume, or cancel active prints.
- **Axis Control**: Jog your printer axes (X,Y,Z), trigger homing, extrude, and retract filament. Include Emergency Stop.
- **Local Notifications (Android 13+)**: Receive background push notifications for print milestones (%10, %20, etc.) and completion states.

### 🛠️ Advanced Network & System Features
- **Tailscale Fallback**: Zero-configuration fallback support. When local IP fails, OctoMobile seamlessly switches to your Tailscale VPN IP for OctoPrint API, WebSockets, and SSH connections out of the box.
- **Embedded Terminal**: Direct communication with your printer via a native G-code console.
- **Z-Offset and Feedrate**: Real-time tuning controls extending standard printer parameters.

### 🖥️ System Health (via SSH)
- **Raspberry Pi Integration**: Securely connect to your host via `dartssh2` directly from the app.
- **Live Server Stats**: Real-time CPU temperature polling, CPU load, and RAM consumption visualized beautifully.
- **SSH Emulator**: Embedded `xterm.js` emulator for executing bash scripts or server management without leaving the app.

---

## 🛠️ Technical Stack

- **Framework**: [Flutter](https://flutter.dev/) (Channel: stable)
- **State Management**: [Riverpod](https://riverpod.dev/) for robust and reactive architecture.
- **Communication**: 
    - WebSocket for real-time printer telemetry and status parsing.
    - REST API (OctoPrint API).
    - SSH (`dartssh2`) for system-level Raspberry Pi access.
- **UI/UX**: 
    - [Google Fonts](https://fonts.google.com/) (Inter, Outfit, etc.)
    - Core Material 3 with Custom Dark Glass Theme
- **Networking**: `http`, `web_socket_channel`.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest version recommended)
- An OctoPrint instance reachable from your device.
- SSH access enabled on your Raspberry Pi (Optional, for system monitoring).

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/mrydev/octomobile.git
   cd octomobile
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

---

## 🌍 Localization
OctoMobile focuses on accessibility and currently supports:
- 🇹🇷 **Turkish** (Native support)
- 🇺🇸 **English** (Universal)

*(Both app UI and notifications are dynamically localized based on device settings).*

---

## 🤝 Contributing
Contributions are welcome! Whether it's a bug report, feature request, or a pull request, your help is appreciated.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.

---

Developed with ❤️ by MryDEV and Gemini
