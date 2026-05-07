# External Integrations

**Analysis Date:** 2026-05-07

## APIs & External Services

**Network Service Discovery (NSD):**
- `nsd` 5.0.1 - Cross-platform network service discovery
  - Location: `packages/core/pubspec.yaml:8`
  - Purpose: Enables local network device/service discovery between DM app and companion app
  - Platform plugins: `nsd_android`, `nsd_ios`, `nsd_macos`, `nsd_windows`
  - This is the **only external service integration** in the workspace

**Note:** This is an early-stage workspace. No cloud APIs, backend services, or third-party integrations are configured yet.

## Data Storage

**Databases:**
- None configured

**File Storage:**
- Local filesystem only (no cloud storage integration)

**Caching:**
- None configured

## Authentication & Identity

**Auth Provider:**
- None configured

## Monitoring & Observability

**Error Tracking:**
- None

**Logs:**
- No logging framework configured

## CI/CD & Deployment

**Hosting:**
- Not configured

**CI Pipeline:**
- None (no `.github/`, no CI configuration files)

## Environment Configuration

**Required env vars:**
- None defined (no `.env` files detected)

**Secrets location:**
- Not applicable - no secrets configured

## Dependency Graph

```
dnd_workspace (root)
├── core (packages/core)
│   └── nsd ^5.0.1
│       ├── nsd_android 2.2.0
│       ├── nsd_ios 3.0.1
│       ├── nsd_macos 3.0.1
│       ├── nsd_windows 3.0.1
│       └── nsd_platform_interface 2.2.0
│           ├── provider 6.1.5+1
│           ├── plugin_platform_interface 2.1.8
│           ├── uuid 4.5.3
│           │   ├── crypto 3.0.7
│           │   │   └── typed_data 1.4.0
│           │   └── fixnum 1.1.1
│           └── collection, flutter, nested
├── dm_app (apps/dm_app)
│   ├── flutter (SDK)
│   └── core (path: ../../packages/core)
└── companion_app (apps/companion_app)
    ├── flutter (SDK)
    └── core (path: ../../packages/core)
```

## Package Sources

**pub.dev (hosted):**
- All external packages sourced from `https://pub.dev`
- Verified via SHA256 checksums in `pubspec.lock`

**Local (path):**
- `core` package referenced via relative path from both apps

**SDK:**
- `flutter` - Flutter SDK packages

## Webhooks & Callbacks

**Incoming:**
- None

**Outgoing:**
- None

## Platform Support (via NSD)

The `nsd` package provides cross-platform service discovery:

| Platform | Plugin | Version |
|----------|--------|---------|
| Android | `nsd_android` | 2.2.0 |
| iOS | `nsd_ios` | 3.0.1 |
| macOS | `nsd_macos` | 3.0.1 |
| Windows | `nsd_windows` | 3.0.1 |

**Note:** Platform directories (`android/`, `ios/`, `macos/`, `windows/`) have not been created yet in either app. The NSD plugins will require platform setup before they can be used.

---

*Integration audit: 2026-05-07*
