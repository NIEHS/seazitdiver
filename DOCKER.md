# Run SEAZIT DIVER on your own computer (Docker)

This guide runs the SEAZIT DIVER web application **and its database** on your own computer
(Windows, macOS or Linux) using Docker. You do not need to install Python, Node.js, conda or
PostgreSQL.

- Website: <http://localhost:8000/seazit/app/>
- Data: public SEAZIT snapshot of **2026-10-20** (read-only; no user accounts included)
- For local use, demos and development only. It is **not** a production server.

---

## 1. Requirements

| | |
|---|---|
| Operating system | Windows 10/11 (64-bit), macOS (Intel or Apple Silicon), or Linux |
| Software | Docker Desktop (Windows/macOS) or Docker Engine + Compose plugin (Linux); Git (optional) |
| Free disk space | about **12 GB** (images ~3.6 GB, database ~4.5 GB, build files) |
| Memory for Docker | at least **4 GB** |
| Internet | needed on the **first** start only (downloads images, packages and the 106 MB data file) |

---

## 2. Install Docker

### Windows

1. Install **WSL 2**: open *PowerShell as Administrator* and run `wsl --install`, then restart.
2. Install **Docker Desktop**: <https://docs.docker.com/desktop/setup/install/windows-install/>
   (keep the option *Use WSL 2 instead of Hyper-V* checked).
3. Start Docker Desktop and wait until it shows **Engine running**.

### macOS

1. Install **Docker Desktop** for your chip (Apple Silicon or Intel):
   <https://docs.docker.com/desktop/setup/install/mac-install/>
2. Start Docker Desktop and wait until it shows **Engine running**.

### Linux

1. Install **Docker Engine** and the **Compose plugin**: <https://docs.docker.com/engine/install/>
2. Allow your user to run Docker without `sudo`, then log out and back in:

   ```bash
   sudo usermod -aG docker $USER
   ```

### Check Docker (all systems)

Open a terminal (**PowerShell** on Windows, **Terminal** on macOS/Linux) and run:

```bash
docker version
docker compose version
```

Both must print version information without errors.

**Memory:** in Docker Desktop open *Settings → Resources* and make sure Memory is at least 4 GB.

---

## 3. Get the project

Use **one** of the two options.

### Option A - with Git (recommended, easier to update)

```bash
git clone -b seazit-docker-local https://github.com/NIEHS/seazitdiver.git
cd seazitdiver
```

> **Windows + Git:** if Git asks, or you see `\r: command not found` errors later, clone with
> `git clone -c core.autocrlf=false -b seazit-docker-local https://github.com/NIEHS/seazitdiver.git`

### Option B - Download ZIP (no Git needed)

1. Open <https://github.com/NIEHS/seazitdiver/tree/seazit-docker-local>
2. Make sure the branch selector shows **seazit-docker-local**.
3. Click **Code → Download ZIP** and unzip it.
4. Open a terminal **inside the unzipped folder** (the folder that contains `docker-compose-local.yml`):
   - Windows: open the folder in File Explorer, click the address bar, type `powershell`, press Enter.
   - macOS: right-click the folder in Finder → *New Terminal at Folder*.
   - Linux: `cd` into the folder.

---

## 4. Start SEAZIT (first time)

In the project folder run:

```bash
docker compose -f docker-compose-local.yml up --build
```

> Always include `-f docker-compose-local.yml`. Without it Docker reports
> *"no configuration file provided"*.

What happens on the first start (about **5-15 minutes**, depending on your computer and internet):

1. Docker builds two images: `seazit-django` (the web app) and `seazit-db` (PostgreSQL 16).
2. The database container downloads the data file `data.dump` (106 MB) from the
   [GitHub Release](https://github.com/NIEHS/seazitdiver/releases/tag/data-2026-10-20)
   and restores it (~3 GB, under a minute). You will see:

   ```
   db-1  | seazit: sha256 OK
   db-1  | seazit: restore complete
   ```

3. The web app starts. You will see:

   ```
   django-1  | SEAZIT is running at http://localhost:8000
   ```

Keep this terminal window open - closing it or pressing `Ctrl+C` stops SEAZIT.

---

## 5. Open SEAZIT

Open in your web browser: **<http://localhost:8000/seazit/app/>**

---

## 6. Everyday use

Run these in the project folder:

| Task | Command |
|---|---|
| Start (in the background) | `docker compose -f docker-compose-local.yml up -d` |
| Stop (keeps the data) | `docker compose -f docker-compose-local.yml down` |
| Status | `docker compose -f docker-compose-local.yml ps` |
| App logs | `docker compose -f docker-compose-local.yml logs -f django` |
| Database logs | `docker compose -f docker-compose-local.yml logs db` |

After the first start, starting again takes only a few seconds (the data is kept).

---

## 7. Admin login (optional)

The data does not include any user accounts. To use the admin pages, create your own login
(while SEAZIT is running):

```bash
docker compose -f docker-compose-local.yml exec django python manage.py createsuperuser
```

Then open <http://localhost:8000/batcave/>.

---

## 8. Updating

**New program version** (code changes):

```bash
git pull                     # Option B: download and unzip the new ZIP instead
docker compose -f docker-compose-local.yml up -d --build
```

**New data version** (or to reset the database to the original data):

```bash
docker compose -f docker-compose-local.yml down -v     # -v deletes the local database
docker compose -f docker-compose-local.yml up -d       # restores the data again
```

---

## 9. Troubleshooting

| Problem | Solution |
|---|---|
| `Cannot connect to the Docker daemon` / `docker: command not found` | Start Docker Desktop (Windows/macOS) or `sudo systemctl start docker` (Linux), wait until it is running. |
| `no configuration file provided` | Add `-f docker-compose-local.yml` and run the command **inside the project folder**. |
| `port is already allocated` / port 8000 in use | Create a file named `.env` in the project folder containing `SEAZIT_PORT=8080`, start again, and open <http://localhost:8080/seazit/app/>. |
| Database log shows `ERROR could not download data.dump` (proxy, firewall, offline) | Download **data.dump** with your web browser from <https://github.com/NIEHS/seazitdiver/releases/tag/data-2026-10-20>, save it as `local_data/data.dump` in the project folder, then run `docker compose -f docker-compose-local.yml down -v` and `docker compose -f docker-compose-local.yml up -d`. |
| Website does not open / `django` keeps restarting | Check `docker compose -f docker-compose-local.yml logs db` - the database must show `seazit: restore complete` first. |
| `\r: command not found` or `bad interpreter` (Windows) | The files got Windows line endings. Delete the folder and clone again with `git clone -c core.autocrlf=false ...` (or use the ZIP). |
| Build fails with `no space left on device` | Free disk space, then run `docker system prune` and try again. |
| Build is very slow / fails while downloading packages | Check your internet/VPN connection and run the `up --build` command again (it continues where it stopped). |
| Want to start completely fresh | See *Uninstall* below, then follow section 4 again. |

When asking for help, include the output of:

```bash
docker compose -f docker-compose-local.yml ps
docker compose -f docker-compose-local.yml logs --tail 50 db django
```

---

## 10. Uninstall

```bash
docker compose -f docker-compose-local.yml down -v      # remove containers and the database
docker rmi seazit-django seazit-db:16                   # remove the images
docker builder prune -f                                 # optional: remove build cache
```

Then delete the project folder.

---

## 11. For maintainers

- Docker files: `docker-compose-local.yml`, `compose/local/Dockerfile` (web app),
  `compose/local/db.Dockerfile` (database), `compose/local/start.sh`,
  `project/main/settings/docker.py`.
- Database loading and publishing a new data version: [`local_data/README.md`](local_data/README.md).
- Server deployments do **not** use these files; they use `docker-compose-production.yml`
  via `NIEHS/deploy-seazit`.
