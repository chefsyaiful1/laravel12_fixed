
# Laravel 12 Project Custom Scripts

This project includes several custom Artisan commands to automate setup, cloning, and PWA features.

---

## 1. Project Setup

Command: 

```bash
php artisan app:project-setup [--force] [--fresh]
```

**Options:**

- `--force` : Force run migrations and seeders even if up-to-date.  
- `--fresh` : Drop all tables and rerun migrations.  

**Purpose:**  
- Run pending migrations or fresh migration  
- Seed `AdminSeeder` and `DatabaseSeeder`  
- Clear caches and optimize  
- Create storage symbolic link  

---

## 2. Clone & PWA Setup

Command: 

```bash
php artisan app:clone-pwa [--pwa] [--clone=<folder_name>]
```

**Options:**

- `--pwa` : Install and configure PWA support  
- `--clone=<folder_name>` : Clone current Laravel project to a new folder  

**Purpose:**  
- PWA setup includes installing package, publishing config & assets  
- Clone project to a new folder, generate fresh `.env` and new `APP_KEY`  

**Post-clone Steps:**  
1. Navigate to cloned folder: `cd <folder_name>`  
2. Install dependencies: `composer install`  
3. Run migrations: `php artisan migrate`  
4. Seed Admin: `php artisan db:seed --class=AdminSeeder`  
5. Create storage link: `php artisan storage:link`  

---

## Notes

- These scripts are designed to speed up initial setup for new Laravel instances.  
- For multi-tenant setups, the cloned project can be used as a base to implement tenancy.  
- Ensure PHP CLI, Composer, and file permissions are correctly configured for cloning and Artisan commands.
