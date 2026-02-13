# Firefox + AutoFirma in Docker (Wayland/X11)

A containerized environment for running Firefox and AutoFirma seamlessly on Linux, specifically optimized for Wayland (e.g., NixOS, Fedora, GNOME/Plasma) while maintaining X11 compatibility.

This project solves the complexity of installing AutoFirma and its dependencies by isolating them in a Docker container, ensuring proper integration with the host's graphical server and persistent user data.

## Features

- **Base Image**: Ubuntu 24.04 (Noble Numbat).
- **Native Firefox**: Installed via the `mozillateam/ppa` to avoid Snap-related issues in Docker.
- **AutoFirma 1.9**: Pre-installed and configured to work with the browser.
- **Configurador FNMT**: Included to handle certificate requests and downloads from the Spanish Mint (FNMT).
- **Graphical Support**: Native Wayland support with XWayland fallback.
- **Automatic Integration**: 
    - Auto-registration of the `afirma://` and `fnmt://` protocol handlers.
    - Automatic injection of the AutoFirma Root Certificate into the Firefox profile.
- **User Mapping**: Maps host UID/GID (default 1000:1000) to the container user to prevent permission issues.
- **Persistence**: Firefox profile, certificates, and downloads are persisted in the `./home` directory on the host.

## Included Software

| Software | Version | Source |
|----------|---------|--------|
| **Firefox** | Latest (PPA) | [Mozilla Team PPA](https://launchpad.net/~mozillateam/+archive/ubuntu/ppa) |
| **AutoFirma** | 1.9 | [Portal de Administración Electrónica](https://firmaelectronica.gob.es/Home/Descargas.html) |
| **Configurador FNMT** | 5.0.3 | [FNMT Downloads](https://www.sede.fnmt.gob.es/descargas/descarga-software) |
| **OpenJDK** | 17 | [Ubuntu Repositories](https://packages.ubuntu.com/) |

## Prerequisites

- **Docker** and **Docker Compose**.
- A Linux host with **Wayland** or **X11**.
- For Wayland: Ensure your user has permissions to access the Wayland socket (usually handled automatically by the UID mapping).

## Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/autofirma-docker.git
   cd autofirma-docker
   ```

2. **Launch the container:**
   ```bash
   # If your user UID/GID is 1000:1000
   docker-compose up --build
   ```
   If your UID/GID is different:
   ```bash
   UID=$(id -u) GID=$(id -g) docker-compose up --build
   ```

3. **Verify:**
   - Firefox will open automatically.
   - To test AutoFirma, visit a Spanish government site (e.g., [Valide](https://valide.redsara.es/valide/)) and try to sign a document.
   - The root certificate is imported on the first run. You can check it in Firefox: `Settings -> Privacy & Security -> Certificates -> View Certificates -> Authorities` (look for "AutoFirma ROOT").

## Configuration & Persistence

- **Downloads**: Files downloaded in Firefox appear in `./home/Downloads` on your host.
- **Firefox Profile**: Stored in `./home/.mozilla`.
- **Certificates**: Stored in `./home/.afirma`.

### Hardware Tokens (DNIe / Smart Cards)

If you use a physical smart card reader, you may need to pass the USB device to the container. Uncomment the `devices` section in `docker-compose.yml`:

```yaml
# devices:
#   - "/dev/bus/usb:/dev/bus/usb"
```
