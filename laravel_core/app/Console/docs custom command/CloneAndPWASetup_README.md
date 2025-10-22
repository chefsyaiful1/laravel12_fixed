
# Laravel Clone & PWA Setup Command

This command automates setting up a Laravel project clone with optional PWA features.

## Command

```bash
php artisan app:clone-pwa-setup [options]
```

### Options

- `--force` : Force run migrations, seeders, and storage link even if already done.
- `--fresh` : Drop all tables and rerun migrations from scratch.
- `--pwa`   : Set up basic PWA manifest and service worker files.

### Steps Performed

1. **Ensure `.env` exists**: Creates `.env` from `.env.example` if missing.
2. **Generate `APP_KEY`**: Secures the application key.
3. **Handle migrations**:
   - `--fresh`: Drops all tables and reruns migrations.
   - Else, runs pending migrations if any.
4. **Seed database**:
   - `AdminSeeder` for superadmin account.
   - `DatabaseSeeder` for default data.
5. **Storage link**: Creates `public/storage` symbolic link if missing.
6. **Optional PWA setup**:
   - Creates `manifest.json` in `public/`.
   - Creates `service-worker.js` in `public/` for basic caching.
7. **Clear caches & optimize**: Clears config, route, cache, and view caches.

### Default Superadmin Login

- Email: `admin@example.com`
- Password: `password`

### Example Usage

```bash
# Normal setup
php artisan app:clone-pwa-setup

# Force migrations/seeders and storage link
php artisan app:clone-pwa-setup --force

# Fresh migrations from scratch
php artisan app:clone-pwa-setup --fresh

# Include PWA setup
php artisan app:clone-pwa-setup --pwa

# Combine all options
php artisan app:clone-pwa-setup --fresh --force --pwa
```

### Notes

- Ensure `.env.example` exists before running the command.
- The PWA setup is minimal and can be extended as needed.
- The command is intended for cloning Laravel projects as core templates for other projects.
