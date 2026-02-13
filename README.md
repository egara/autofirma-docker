# Autofirma & Firefox in Docker (Wayland/NixOS friendly)

Este proyecto levanta un contenedor con Firefox y Autofirma preconfigurados y conectados.

## Requisitos previos

- Docker
- Docker Compose
- Un entorno de escritorio Wayland (o X11 con configuración adicional)

## Uso

1.  **Construir y levantar el contenedor:**

    ```bash
    # Si tu usuario es 1000:1000 (común en Linux/NixOS)
    docker-compose up --build
    ```

    Si tu UID/GID es diferente:

    ```bash
    UID=$(id -u) GID=$(id -g) docker-compose up --build
    ```

2.  **Verificar funcionamiento:**
    - Firefox se abrirá automáticamente.
    - Autofirma debería estar disponible. Puedes probar a firmar un documento en una sede electrónica.
    - El certificado raíz de Autofirma se importa automáticamente en Firefox al inicio.

3.  **Persistencia:**
    - Los datos de usuario (perfil de Firefox, descargas) se guardan en `./home` en el directorio actual.

## Notas sobre Wayland y NixOS

- El `docker-compose.yml` monta el socket de Wayland (`$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY`).
- Si tienes problemas gráficos, asegúrate de que tu usuario tiene permisos sobre el socket (al usar el mismo UID que el host, esto debería ser automático).
- Si prefieres usar XWayland (X11), asegúrate de tener `xhost +local:docker` ejecutado en el host y que la variable `DISPLAY` se pase correctamente (ya incluido en el compose).

## Solución de problemas

- **Autofirma no se abre al intentar firmar:** Asegúrate de que el certificado "AutoFirma ROOT" está en las Autoridades de Firefox (Ajustes -> Privacidad -> Ver Certificados). El script de inicio intenta añadirlo automáticamente.
- **Smart Cards / DNIe:** Si usas lector físico, puede que necesites descomentar las líneas de `devices` en `docker-compose.yml` para pasar el USB (`/dev/bus/usb`).
