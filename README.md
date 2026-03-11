# Gearence

**Gearence** is a high-performance, third-party mobile documentation reader for the **Godot Engine**. Built for developers who need instant access to class references on the go, it provides a native, buttery-smooth experience even on resource-constrained hardware.

**[Download on Google Play](https://play.google.com/store/apps/details?id=com.fengjiongmax.godotclassreference)** | **[Download on AppStore](https://apps.apple.com/qa/app/godot-class-reference/id1523486419)** | **[Official Website](https://godotdocmobile.github.io/)**

---

## ✨ Features

* **Binary Speed**: Powered by **Isar Database**. Documentation is pre-compiled into binary format for near-instant search and zero-latency tab switching.
* **Multi-Version Support**: Browse Godot **2.0 through 4.x**.
* **Smart Redirects**: Deep-link support for Methods, Signals, and Properties. Tap a type to jump directly to its definition.
* **Low-Power Optimization**: Engine-level optimizations designed to provide a smooth experience on entry-level hardware and media-consumption devices.
* **Offline First**: Full documentation is cached locally for reliable access in the field.


## 🛠️ Development

### Prerequisites

* **Flutter SDK**: Latest stable version.

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/GodotDocMobile/Gearence.git
cd Gearence

```


2. **Sync Data (Tools):**
Before running the app, you can use the sync tool to fetch the latest compiled binaries:
```bash
flutter run bin/fetch_isar.dart -output ../assets/ --force

```


3. **Run the app:**
```bash
flutter run

```

---

## 🤝 Contributing

We love contributions! Since we've moved to a binary-dist model, please focus PRs on the **Flutter UI** or the **Dart Tooling**.

1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/Optimization`).
3. Commit your Changes (`git commit -m 'Improve search latency'`).
4. Push to the Branch.
5. Open a Pull Request.

## ⚖️ License

Distributed under the **GNU General Public License v3.0**. See `LICENSE` for more information.

---

*Gearence is an independent project and is not affiliated with the official Godot Engine team.*
