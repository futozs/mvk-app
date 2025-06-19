# MVK App 🚌

Modern Flutter alkalmazás a Miskolci Városi Közlekedés (MVK) menetrendjének és járatkövetésének megjelenítésére.

## FIGYELEM - ALPHA VERZIÓ!

**EZ AZ ALKALMAZÁS MÉG CSAK EGY ÖTLET SZINTJÉN VAN!**

- **NINCS BEFEJEZVE** - A fejlesztés még korai szakaszban tart
- **NEM HASZNÁLHATÓ ÉLES KÖRNYEZETBEN** - Csak tesztelési célokra
- **HIÁNYOS FUNKCIÓK** - Sok funkció még nem implementált
- **HIBÁK VÁRHATÓAK** - Az alkalmazás instabil lehet
- **FOLYAMATOS FEJLESZTÉS ALATT** - Minden naponta változhat

**Ez egy kísérleti projekt és proof-of-concept! Használd saját felelősségre!**

## Funkciók

- Modern, felhasználóbarát felület
- Interaktív térkép openstreetmap integráció
- Valós idejű járatkövetés
- Részletes menetrend és útvonaltervezés
- GPS alapú helymeghatározás
- Szép animációk és átmenetek

## Technológiák

- **Flutter** - Cross-platform fejlesztés
- **Bloc** - Állapotkezelés
- **Openstreetmap** - Térképmegjelenítés
- **Hive** - Helyi adattárolás
- **GTFS** - Közlekedési adatok
- **Material Design** - Modern UI

## Fejlesztés

Ez az alkalmazás **AI közreműködésével** lett létrehozva "vibe coded" módszerrel - a modern fejlesztés és mesterséges intelligencia kombinációjaként.

## Futtatás

```bash
# Függőségek telepítése
flutter pub get

# Környezeti változók beállítása
# 1. Másold le a .env.example fájlt .env néven
cp .env.example .env

# 2. Szerkeszd a .env fájlt és add meg a saját API kulcsaidat
# WEATHER_API_KEY=your_openweathermap_api_key_here

# Alkalmazás futtatása debug módban
flutter run --debug

# APK build
flutter build apk
flutter build apk --no-tree-shake-icons
```

## Környezeti változók

Az alkalmazás `.env` fájlt használ az API kulcsok és egyéb érzékeny adatok tárolására. 

### Beállítás:

1. **Másold le a példa fájlt:**
   ```bash
   cp .env.example .env
   ```

2. **Szerkeszd a `.env` fájlt:**
   ```env
   WEATHER_API_KEY=your_api_key_here
   ```

3. **OpenWeatherMap API kulcs beszerzése:**
   - Menj a [OpenWeatherMap](https://openweathermap.org/api) oldalra
   - Regisztrálj egy ingyenes fiókot
   - Másold ki az API kulcsot a `.env` fájlba

**⚠️ FONTOS: A `.env` fájl nincs verziókezelés alatt! Soha ne commitold az API kulcsaidat!**

## Képernyőképek 📱

<div align="center">
  <table>
    <tr>
      <td align="center">
        <a href="https://cdn.futozsombor.hu/u/BIfWO9.jpg">
          <img src="https://cdn.futozsombor.hu/u/BIfWO9.jpg" width="200" alt="Betöltő képernyő">
        </a>
        <br>
        <em>Betöltő képernyő</em>
      </td>
      <td align="center">
        <a href="https://cdn.futozsombor.hu/u/jl4COt.jpg">
          <img src="https://cdn.futozsombor.hu/u/jl4COt.jpg" width="200" alt="Főoldal">
        </a>
        <br>
        <em>Főoldal</em>
      </td>
    </tr>
    <tr>
      <td align="center">
        <a href="https://cdn.futozsombor.hu/u/qbYJYl.jpg">
          <img src="https://cdn.futozsombor.hu/u/qbYJYl.jpg" width="200" alt="Kedvencek">
        </a>
        <br>
        <em>Kedvencek</em>
      </td>
      <td align="center">
        <a href="https://cdn.futozsombor.hu/u/kgmEVD.jpg">
          <img src="https://cdn.futozsombor.hu/u/kgmEVD.jpg" width="200" alt="Beállítások">
        </a>
        <br>
        <em>Beállítások</em>
      </td>
    </tr>
  </table>
</div>

*Kattints a képekre a nagyobb méretű megjelenítéshez*

## Licensz
minekaz'

Ez a projekt oktatási és demonstrációs célokra készült!!!
