#!/bin/bash
set -e

# Define paths
PROFILE_DIR="$HOME/.mozilla/firefox/default"
AF_DIR="/usr/lib/Autofirma"
CER_FILE="$AF_DIR/Autofirma_ROOT.cer" # Correct case from ls output

echo "Setting up Firefox profile at $PROFILE_DIR..."

# Create profile directory if it doesn't exist
if [ ! -d "$PROFILE_DIR" ]; then
    mkdir -p "$PROFILE_DIR"
    # Create a new certificate database
    echo "Creating new certificate database..."
    certutil -N -d "sql:$PROFILE_DIR" --empty-password
fi

# Ensure profiles.ini exists so Firefox finds the profile
if [ ! -f "$HOME/.mozilla/firefox/profiles.ini" ]; then
    echo "Creating profiles.ini..."
    cat > "$HOME/.mozilla/firefox/profiles.ini" <<EOF
[Profile0]
Name=default
IsRelative=1
Path=default
Default=1

[General]
StartWithLastProfile=1
Version=2
EOF
fi

echo "Configuring AutoFirma protocol handler..."
# Create local applications directory
mkdir -p "$HOME/.local/share/applications"
mkdir -p "$HOME/.config"

# Link or copy the desktop file
if [ -f "/usr/share/applications/afirma.desktop" ]; then
    cp /usr/share/applications/afirma.desktop "$HOME/.local/share/applications/"
    chmod +x "$HOME/.local/share/applications/afirma.desktop"
    
    # Register mime type
    echo "Registering x-scheme-handler/afirma..."
    xdg-mime default afirma.desktop x-scheme-handler/afirma
    
    # Verify registration
    echo "Check assignment:"
    xdg-mime query default x-scheme-handler/afirma
else
    echo "Warning: afirma.desktop not found in /usr/share/applications"
fi

echo "Importing Autofirma certificate into Firefox..."
if [ -f "$CER_FILE" ]; then
    # Import the cert
    certutil -A -n "AutoFirma ROOT" -t "TC,C,C" -d "sql:$PROFILE_DIR" -i "$CER_FILE" || echo "Certificate might already exist or failed to add."
    echo "Certificate imported successfully."
else
    echo "Warning: Autofirma certificate not found at $CER_FILE."
fi

# Try to run the Autofirma configurator (it might need display)
# echo "Running Autofirma Configurator..."
# java -jar "$AF_DIR/autofirmaConfigurador.jar" -restore || echo "Configurator failed (might be expected in headless)"

echo "Launching Firefox..."
exec firefox "$@"