> [!NOTE]
> **Project Status (Beta / Open to Contributions):**  
> This project is currently in functional **Beta**. It already provides a complete, daily-usable experience on a vanilla AkelPad installation. However, because I am currently occupied with several other projects, I cannot dedicate all the time needed to bring it to a 100% "finished" state or test every third-party plugin dock.  
> The code is shared openly so that anyone interested can fork, refine, or expand upon it!

![image](https://i.ibb.co.com/MkLnZRrB/Akel-Pad-Dark-Mode.png)

---

### ✨ Features

* **Dynamic On-The-Fly Theming:** Enable or disable dark mode instantly via the Plugins dialog without needing to restart AkelPad.
* **Native Windows 10/11 Title Bar:** Integrates with system DWM attributes and UxTheme composition APIs (`AllowDarkModeForWindow`, `SetWindowCompositionAttribute`) to enforce dark window borders and caption bars on modern Windows builds (1809+ / Windows 11).
* **Dark Menu Bar & System Buttons:** Custom rendering of the non-client menu bar (`UAHMENU`), including dark backgrounds, hover states, and dark caption buttons (Minimize, Restore, Close).
* **Modern Tab & Status Bars:**
  * Custom dark tab strip with active accent indicators and mouse hover effects.
  * Darkened status bar with custom section dividers and sizing grips.
* **Deep Common Controls Subclassing:**
  * **Buttons & GroupBoxes:** Custom GDI/GDI+ painting for PushButtons, GroupBoxes, Checkboxes, and Radio buttons with anti-aliased glyphs.
  * **ComboBoxes & ListBoxes:** Custom border overrides, dark drop-down list hooking, and owner-draw handling.
  * **ListViews & Headers:** Dark item backgrounds, selection colors, and custom dark column header borders.
  * **UpDown / Spin Controls:** Handled and repainted with custom dark arrows and hover feedback.
  * **Static Controls:** Custom horizontal separators, color swatch pickers, and sample preview boxes.
* **Automatic Dialog Hooking:** Uses a global thread CBT hook (`WH_CBT`) to trap and instantly theme newly opened dialog windows (`#32770`) such as Font selection and Color pickers.
* **Pure Native Performance:** Zero heavy runtimes or web-engine overhead; built strictly with native Win32 APIs, GDI, and GDI+.

---

### 🛠 Technical Details

* **Language:** 100% FreeBASIC (Structured, modular codebase).
* **Interface:** AkelPad Native Plugin API (`AkelDLL.bi`).
* **Theming Engine:**
  * Undocumented UxTheme / DWM exports (`SetWindowCompositionAttribute`, `AllowDarkModeForWindow`, `SetPreferredAppMode`, `FlushMenuThemes`).
  * Thread-level CBT Hook (`WH_CBT`) to detect window activation.
  * Extensive Win32 **Window Subclassing** via `comctl32.dll`.
* **Graphics:** Windows GDI combined with **GDI+** for anti-aliased shape and vector rendering.
* **Architecture:** Compiles natively to 32-bit (x86) and 64-bit (x64) Windows DLLs with zero external dependencies.

---

### ⚙️ Compilation

To compile the plugin from source:

1. Install the [FreeBASIC Compiler](https://www.freebasic.net/) (`fbc`) and ensure it is available in your system's `PATH`.
2. Open a terminal / command prompt in the root directory of this repository.
3. Run the included build script:
   ```cmd
   Compile.bat
   ```
   Or invoke the compiler manually:
   ```cmd
   fbc -dll -gen gcc "AkelDarkMode.bas"
   ```
4. This will generate **`AkelDarkMode.dll`**.

---

### 📦 Installation

1. Close AkelPad if it is running.
2. Copy the compiled **`AkelDarkMode.dll`** into your AkelPad plugins folder:
   ```text
   <AkelPad_Directory>\AkelFiles\Plugs\
   ```
   *(Typical path: `C:\Program Files\AkelPad\AkelFiles\Plugs\`)*
3. Launch AkelPad.
4. Press **`Alt+P`** (or go to `Options -> Plugins...`), find **`AkelDarkMode::Main`**:
   * Click **Call** to toggle dark mode on or off.
   * Check **Autoload** if you want dark mode enabled automatically upon starting AkelPad.

---

### ⚠️ Current Limitations & Roadmap

* **Vanilla Focus:** Tested primarily on clean/vanilla AkelPad installations.
* **Third-Party Plugins:** Compatibility with complex dockable panels (e.g., *Explorer*, *Coder*, *ToolBar*) has not yet been fully audited and may require additional subclassing routines or exclusions.
* **Edge-case Controls:** Some custom-drawn controls in third-party dialogs might still show light backgrounds.

---

### 🤝 Contributing

Contributions, bug fixes, and improvements are very welcome!  
If you have experience with **FreeBASIC** or **Win32 API/Subclassing** and want to help polish control edge cases, add High-DPI enhancements, or improve compatibility with other AkelPad plugins
