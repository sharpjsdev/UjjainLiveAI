# 🕉️ Ujjain Live - Mobile Application (Flutter)

<p align="center">
  <b>॥ हर हर महादेव • जय श्री महाकाल ॥</b><br>
  <i>The Flutter Client for Ujjain Live & Simhastha 2028 Digital Guide</i>
</p>

---

## 📱 Screenshots

<div align="center">
  <table>
    <tr>
      <td align="center" width="33%">
        <b>🌟 Divine Splash Screen</b><br>
        <img src="../readmeasset/Image%20(3).jpg" alt="Splash Screen" width="260" />
      </td>
      <td align="center" width="33%">
        <b>🏛️ Main Pilgrimage Guide</b><br>
        <img src="../readmeasset/Image%20(4).jpg" alt="Home Screen" width="260" />
      </td>
      <td align="center" width="33%">
        <b>💬 AI Chat & Google Maps</b><br>
        <img src="../readmeasset/Image%20(5).jpg" alt="AI Chat" width="260" />
      </td>
    </tr>
  </table>
</div>

---

## ✨ Mobile App Capabilities

- **Hybrid Dual AI**:
  - **Online**: Google Gemini (`gemini-3.5-flash-lite`) with live database context.
  - **Offline**: Complete local database of 18+ temples, Aarti schedules, and Simhastha dates.
- **Voice Recognition & Auto-Listen (STT + TTS)**:
  - Continuous speech dictation for asking questions in Hindi and English.
  - Automatic voice readout of AI responses with raw URLs removed for smooth listening.
  - Interactive `[🔊 Listen ON]` toggle in the AppBar and `[■ Stop]` on bubbles.
- **Dynamic Place-Based Google Maps Routing**:
  - Generates verified Google Maps search and directions links with official place names for 100% accuracy.
- **Live GPS Proximity**:
  - Distance and travel time calculations from user's current GPS location.

---

## 🚀 Running the App

```bash
# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Build release APK
flutter build apk --release
# Or run the batch script:
.\build_apk_now.bat
```

For full project documentation and backend configuration, refer to the root [README.md](../README.md).
