# Local Music Player

A local-first music library and player for Windows (and, in progress, Android) built with Flutter. No accounts, no cloud, no streaming — it scans folders you point it at, reads embedded metadata and cover art, and plays what it finds.

**Live demo:** _not applicable — desktop/mobile app, not a web service_
**Platform status:** Windows working · Android in progress (see Known Issues)
**Related repo:** [local-comic-library-reader](https://github.com/TheIlkinAlizade/local-comic-library-reader) — a similar local-first project for comics

---

## What it does

- Scans one or more folders recursively for `.mp3` / `.flac` / `.m4a` / `.wav` files
- Extracts embedded metadata (title, artist, album, track/disc number, year, genre) and embedded cover art per file
- Cover art is deduplicated by content hash, so an album with twelve tracks that all embed the same image stores it once, not twelve times
- Re-scanning a folder skips files that haven't changed since the last scan, so relaunching the app doesn't re-parse the whole library
- Library is browsable as a grid or list, sortable (title/artist/album/date added/file size/favorites) and searchable
- Artist and Album views are generated from the same metadata, each with a detail page listing tracks in correct track/disc order
- Playlists: create, add/remove tracks, drag-to-reorder
- Playback: shuffle, repeat (off/all/one), seek, auto-advance to the next track, a visible/editable upcoming queue
- A collapsible mini player (a resized, blurred-cover-art window on desktop)
- The app's background glow is generated at runtime from the currently playing track's cover art — a small custom color extractor, not a third-party palette library
- Settings: remove individual indexed folders, or reset the whole library (tracks, playlists, cached art) without touching the actual music files on disk
- Responsive layout: collapsible sidebar and adaptive player bar on desktop, a dedicated phone layout (drawer navigation, slim player bar) below 600px width

## Tech stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Windows desktop target; Android in progress) |
| Local database | `drift` (SQLite), reactive queries |
| Metadata / cover art | `metadata_god` (Rust-backed via `flutter_rust_bridge`) |
| Playback | `just_audio` + `just_audio_windows` |
| Desktop window control | `window_manager` (mini player resize) |
| Folder/file access | `file_picker`, `path_provider` |
| Image handling | `image` (custom palette extraction, no third-party palette lib) |
| Fonts | `google_fonts` |

## Screens / areas

| Area | Details |
|---|---|
| Home / Library | Grid or list view of all tracks, sort + search, scan-folder bar |
| Favorites | Filtered view of favorited tracks |
| Artists | Grouped by artist, tap through to an artist's tracks |
| Albums | Grouped by album + artist, tracks shown in disc/track order |
| Playlists | Create, reorder, remove tracks |
| Queue panel | View and reorder what's playing next |
| Settings | Manage indexed folders, reset library |
| Mini player | Full-bleed blurred cover art, basic transport controls |

## Prerequisites

- Flutter SDK (stable channel)
- Windows: Visual Studio Build Tools (Desktop C++ workload) + `rustup` (Rust toolchain — `metadata_god` compiles native code at build time)
- Android: Android SDK + a device or emulator (NDK installs automatically on first build)

## Setup

### 1. Clone and install dependencies

```bash
git clone https://github.com/TheIlkinAlizade/flutter-local-music-player.git
cd flutter-local-music-player
flutter pub get
```

### 2. Generate the database code

```bash
dart run build_runner build
```

This generates `app_database.g.dart` from the `drift` schema — required before the first run, and after any schema change.

### 3. Run it

```bash
flutter run -d windows
```

or, for Android, with a device/emulator connected:

```bash
flutter run -d <device-id>
```

### 4. Add music

Open the app, click **Add Folder**, and pick a folder containing audio files. The scan bar shows live progress; tracks appear in the library as they're indexed.

## Known issues / in progress

- **Android playback**: currently silent after tapping a track — under active debugging.
- **Android folder scanning**: deliberately unimplemented. Scoped storage means "pick a folder, read files under it" doesn't work the way it does on desktop. Two real options are documented directly in `lib/core/scanning/unsupported_folder_scanner.dart`: a SAF folder-tree picker (matches the desktop UX, more plumbing) vs. a MediaStore query (simpler, no folder picker). Not yet decided/built.
- App/window icon and display name are still the Flutter defaults.

## Project structure

```
lib/
  core/
    database/      drift schema + queries
    scanning/       folder scanning, metadata extraction, cover art cache
    playback/       PlayerController (queue, shuffle, repeat, playback state)
    theme/          colors, theme, runtime cover-art palette extraction
  screens/
    shell/          app shell, sidebar, player bar, mini player, responsive layout
    library/        grid/list library view + toolbar
    artists/        artist grid + detail
    albums/         album grid + detail
    playlists/      playlist detail (reorder, remove)
    queue/          upcoming-queue panel
    settings/       folder management, library reset
  widgets/          shared UI (glass panel, dialogs, nav items)
```

## License

Personal project, no license chosen yet.