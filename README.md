# 🐙 OctoMobile

![OctoMobile Header](assets/images/readme_header.png)

**OctoMobile** is a premium, open-source Flutter application designed for seamless monitoring and management of your OctoPrint-powered 3D printers. Experience full control of your workshop from your pocket with a modern, high-performance interface.

---

## ✨ Key Features

### 🚀 Real-time Monitoring
- **Dashboard Overview**: Instant access to print progress, time remaining, and status.
- **Temperature Control**: Precise monitoring and control for both Hotend and Heatbed.
- **Webcam Integration**: High-frequency MJPEG stream support for visual monitoring.

### 🛠️ Advanced Tools
- **G-Code Management**: Browse, upload, and manage your print files directly from the app.
- **Embedded Terminal**: Direct communication with your printer via a native G-code console.

### 🖥️ System Health (via SSH)
- **Raspberry Pi Integration**: Monitor your host system's health.
- **Live Stats**: Real-time CPU temperature, usage, and RAM consumption.
- **Maintenance**: Perform system-level tasks via the built-in terminal.

---

## 🛠️ Technical Stack

- **Framework**: [Flutter](https://flutter.dev/) (Channel: stable)
- **State Management**: [Riverpod](https://riverpod.dev/) for robust and reactive architecture.
- **Communication**: 
    - WebSocket for real-time printer telemetry.
    - REST API (OctoPrint API) for commands and file management.
    - SSH (`dartssh2`) for system-level Raspberry Pi access.
- **UI/UX**: 
    - [Google Fonts](https://fonts.google.com/) (Inter, Outfit, etc.)
    - Custom Dark Theme (Aesthetic oriented)
- **Networking**: `http`, `web_socket_channel`.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest version recommended)
- An OctoPrint instance reachable from your device.
- SSH access enabled on your Raspberry Pi (for system monitoring).

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/octomobile.git
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

Developed with ❤️ by [Your Name/Team]
