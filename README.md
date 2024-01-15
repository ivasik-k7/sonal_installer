# Project Setup and SonarQube Integration

This repository contains scripts to simplify the setup and integration of SonarQube, SonarScanner, and Sonar-Flutter for code analysis.

## Prerequisites

Make sure you have the following prerequisites installed on your system:

- [curl](https://curl.se/)
- [jq](https://stedolan.github.io/jq/)
- [unzip](https://linux.die.net/man/1/unzip)

## SonarQube Setup

### Get the Latest SonarQube Version

The script retrieves the latest SonarQube version from GitHub releases.

```bash
SONARQUBE_VERSION=$(curl -sSL https://api.github.com/repos/SonarSource/sonarqube/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
SONARQUBE_DOWNLOAD_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip"
```

### Get the Latest SonarScanner Version

The script retrieves the latest SonarScanner version from GitHub releases.

```bash
SONARSCANNER_VERSION=$(curl -sSL https://api.github.com/repos/SonarSource/sonar-scanner-cli/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
SONARSCANNER_DOWNLOAD_URL="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONARSCANNER_VERSION}.zip"
```

### Sonar Flutter Plugin Setup

The script fetches the latest release information from the [Sonar Flutter GitHub repository](https://github.com/insideapp-oss/sonar-flutter).

```bash
GITHUB_REPO="insideapp-oss/sonar-flutter"
RELEASE_JSON=$(curl -sSL "https://api.github.com/repos/${GITHUB_REPO}/releases/latest")

FLUTTER_SONAR_VERSION=$(echo "${RELEASE_JSON}" | grep '"tag_name":' | cut -d'"' -f4)
ASSET_NAME=$(echo "${RELEASE_JSON}" | jq -r '.assets[] | select(.name | contains("sonar-flutter-plugin")) | .name')

SONAR_FLUTTER_PLUGIN_URL="https://github.com/${GITHUB_REPO}/releases/download/${FLUTTER_SONAR_VERSION}/${ASSET_NAME}"
```

## SonarQube Installation

### Downloading and Installing

The script downloads and installs SonarQube, SonarScanner, and the Sonar Flutter plugin.

```bash
# Download SonarQube
curl -L -o "${SONARQUBE_CACHE}/${SONAR_QUBE_ZIP}" "$SONARQUBE_DOWNLOAD_URL"

# Download Sonar Scanner CLI
curl -L -o "${SONARQUBE_CACHE}/${SONAR_CLI_ZIP}" "$SONARSCANNER_DOWNLOAD_URL"

# Download the Sonar Flutter plugin
curl -L -o "${SONARQUBE_CACHE}/${SONAR_FLUTTER_JAR}" "$SONAR_FLUTTER_PLUGIN_URL"

# Unzip files
unzip -o "${SONARQUBE_CACHE}/${SONAR_QUBE_ZIP}" -d "${SONARQUBE_CACHE}"
unzip -o "${SONARQUBE_CACHE}/${SONAR_CLI_ZIP}" -d "${SONARQUBE_CACHE}"
```

### Installation of Components

The script installs SonarQube and SonarScanner components based on the downloaded files.

```bash
SONAR_SCANNER_COMPONENT=$(find "$SONARQUBE_CACHE" -type d -name "*sonar-scanner*")
SONAR_QUBE_COMPONENT=$(find "$SONARQUBE_CACHE" -type d -name "*sonarqube*")

# Check if SONAR_QUBE_COMPONENT is not empty
if [ -n "$(ls -A "$SONAR_QUBE_COMPONENT")" ]; then
    echo "Installing SonarQube...."
    mkdir -p "$SONAR_QUBE_HOME"
    mv "$SONAR_QUBE_COMPONENT"/* "$SONAR_QUBE_HOME"
else
    echo "$SONAR_QUBE_COMPONENT is empty or does not exist."
fi

# Check if SONAR_SCANNER_COMPONENT is not empty
if [ -n "$(ls -A "$SONAR_SCANNER_COMPONENT")" ]; then
    echo "Installing SonarScanner...."
    mkdir -p "$SONAR_SCANNER_HOME"
    mv "$SONAR_SCANNER_COMPONENT"/* "$SONAR_SCANNER_HOME"
else
    echo "$SONAR_SCANNER_COMPONENT is empty or does not exist."
fi

# Installing sonar-flutter plugin
echo "Installing sonar-flutter plugin ..."
mkdir -p "${SONARQUBE_PLUGINS_DIR}"
mv "${SONARQUBE_CACHE}/${SONAR_FLUTTER_JAR}" "$SONARQUBE_PLUGINS_DIR"

# Clearing the bin
rm -rf -f "$SONARQUBE_CACHE"
```

## SonarScanner Execution

Execute SonarScanner with an optional branch name argument.

```bash
action="console"

if [ "$#" -eq 1 ]; then
    action="$1"
fi

# Validate the argument against allowed values
case "$action" in
"console" | "start" | "stop" | "force-stop" | "restart" | "status" | "dump")
    echo "Valid action: $action"
    ;;
*)
    echo "Invalid action: $action. Allowed values are console, start, stop, force-stop, restart, status, and dump."
    exit 1
    ;;
esac

# SonarQube Setup
SONAR_HOME="$HOME/.sonar"
SONAR_QUBE_HOME="$SONAR_HOME/sonarqube"

# Define the command
sonar_qube_command="${SONAR_QUBE_HOME}/bin/macosx-universal-64/sonar.sh"

# Check if sonar.sh is executable
if [ -x "$sonar_qube_command" ]; then
    echo "SonarQube script is executable. Proceeding with the command."
    bash "$sonar_qube_command" "$action"
else
    echo "SonarQube script is not executable or not found. Please check the installation."
fi
```

Feel free to customize the scripts based on your specific needs and configurations.
