
# Gearence

**Gearence** is a third-party mobile application designed to provide a seamless reading experience for the **Godot Engine Class Reference**. Whether you are commuting or away from your workstation, Gearence allows you to browse documentation for Godot versions 2.0 through 4.x directly on your iOS or Android device.

**[Download on Google Play](https://play.google.com/store/apps/details?id=com.fengjiongmax.godotclassreference)** | **[Download on AppStore](https://apps.apple.com/qa/app/godot-class-reference/id1523486419)** | **[Official Website](https://godotdocmobile.github.io/)**

---

## ✨ Features

* **Multi-Version Support**: Access documentation for Godot versions ranging from legacy 2.0 to the latest 4.x releases.
* **Advanced Navigation**: Effortlessly switch between Classes, Functions, Signals, and Properties with full in-app redirection.
* **Fast Search**: Quickly find the API information you need with an integrated search bar.
* **Reading Comfort**:
* **Dark Mode**: High-contrast theme for low-light environments.
* **Adjustable Text Size**: Customize font sizes for better readability.
* **Code Highlighting**: Includes JetBrains Mono for clean code block rendering.


* **Offline Access**: Once synced, browse documentation without needing an active internet connection.

## 🚀 Getting Started

### Prerequisites

Gearence is built with **Flutter**. To build the project from source, you will need:

* Flutter SDK (Latest stable version)
* Android Studio / Xcode (for mobile deployment)
* Python 3 (for document generation scripts)

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/GodotDocMobile/Gearence.git
cd Gearence

```


2. **Install Flutter dependencies:**
```bash
flutter pub get

```


3. **Run the app:**
```bash
flutter run

```



---

## 🛠️ Updating Documentation (Developers)

The app fetches documentation directly from the official Godot repository. To update the XML documentation used in the app:

1. **Clone the Godot repository:**
```bash
git clone https://github.com/godotengine/godot.git

```


2. **Install Python requirements:**
```bash
pip install GitPython polib
# On Ubuntu 24.04+: sudo apt install python3-git python3-polib

```


3. **Run the update script:**
Navigate to the `scripts` folder and run `godot_repo.py`, pointing it to your local Godot clone:
```bash
cd scripts
python3 godot_repo.py --godot_path /path/to/your/godot/repo

```



---

## 📂 Project Structure

* `lib/`: Main Flutter application logic.
* `scripts/`: Python scripts for pulling and processing Godot XML documentation.
* `xmls/`: Stored class reference data.
* `assets/`: SVGs, fonts (JetBrains Mono), and branding assets.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## ⚖️ License

This project is licensed under the **GNU General Public License v3.0**. See the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.

---

*Gearence is an independent project and is not affiliated with the official Godot Engine team.*
