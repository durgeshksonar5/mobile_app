# Environment & Configuration Guide

## `--dart-define` Build Variables

| Variable Name | Default Value | Description |
| --- | --- | --- |
| `API_BASE_URL` | `http://localhost:8000/api/v1` | Django REST API backend URL |
| `APP_ENV` | `development` | Environment mode (`development`, `staging`, `production`) |

---

## Example Usage

```bash
flutter run --dart-define=API_BASE_URL=https://api.kingwin.example.com/api/v1 --dart-define=APP_ENV=production
```

> [!CAUTION]
> `--dart-define` values are embedded into the compiled binary. Do not use `--dart-define` for private backend database passwords or signing private keys.
