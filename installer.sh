#!/usr/bin/env bash

# ///
# Get the latest SonarQube version from GitHub releases
SONARQUBE_VERSION=$(curl -sSL https://api.github.com/repos/SonarSource/sonarqube/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
SONARQUBE_DOWNLOAD_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip"

# Get the latest SonarScanner version from GitHub releases
SONARSCANNER_VERSION=$(curl -sSL https://api.github.com/repos/SonarSource/sonar-scanner-cli/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
SONARSCANNER_DOWNLOAD_URL="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONARSCANNER_VERSION}.zip"

# Print the download links
GITHUB_REPO="insideapp-oss/sonar-flutter"
RELEASE_JSON=$(curl -sSL "https://api.github.com/repos/insideapp-oss/sonar-flutter/releases/latest")

# Get the latest version and asset name
FLUTTER_SONAR_VERSION=$(echo "${RELEASE_JSON}" | grep '"tag_name":' | cut -d'"' -f4)
ASSET_NAME=$(echo "${RELEASE_JSON}" | jq -r '.assets[] | select(.name | contains("sonar-flutter-plugin")) | .name')

# Construct the download URL
SONAR_FLUTTER_PLUGIN_URL="https://github.com/${GITHUB_REPO}/releases/download/${LATEST_VERSION}/${ASSET_NAME}"

# ///
SONARQUBE_CACHE="${HOME}/.sonar-cache"
SONAR_HOME="$HOME/.sonar"
SONAR_QUBE_HOME="$SONAR_HOME/sonarqube"
SONAR_SCANNER_HOME="$SONAR_HOME/sonarscanner"

SONARQUBE_PLUGINS_DIR="${SONAR_SCANNER_HOME}/extensions/plugins"
# ///
SONAR_FLUTTER_JAR="sonar-flutter-plugin-0.5.0.jar"
SONAR_CLI_ZIP="sonar-cli.zip"
SONAR_QUBE_ZIP="sonarqube.zip"

while getopts ":q:s:f:" opt; do
    case $opt in
    q)
        SONARQUBE_VERSION="$OPTARG"
        ;;
    s)
        SONARSCANNER_VERSION="$OPTARG"
        ;;
    f)
        FLUTTER_SONAR_VERSION="$OPTARG"
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
    esac
done

echo "SonarQube version: $SONARQUBE_VERSION"
echo "SonarScanner version: $SONARSCANNER_VERSION"
echo "Sonar-Flutter version: $FLUTTER_SONAR_VERSION"

mkdir -p "$SONARQUBE_CACHE"

# Download SonarQube
echo "Downloading SonarQube"
curl -L -o "${SONARQUBE_CACHE}/${SONAR_QUBE_ZIP}" "$SONARQUBE_DOWNLOAD_URL"

# Download Sonar Scanner CLI
echo "Downloading Sonar Scanner CLI from ${SONAR_CLI_URL} ..."
curl -L -o "${SONARQUBE_CACHE}/${SONAR_CLI_ZIP}" "$SONARSCANNER_DOWNLOAD_URL"

# Download the Sonar Flutter plugin
echo "Downloading Sonar Flutter plugin from $SONAR_FLUTTER_PLUGIN_URL"
curl -L -o "${SONARQUBE_CACHE}/${SONAR_FLUTTER_JAR}" "$SONAR_FLUTTER_PLUGIN_URL"

echo "Unzipping files..."
unzip -o "${SONARQUBE_CACHE}/${SONAR_QUBE_ZIP}" -d "${SONARQUBE_CACHE}"
unzip -o "${SONARQUBE_CACHE}/${SONAR_CLI_ZIP}" -d "${SONARQUBE_CACHE}"

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

echo "Installing sonar-flutter plugin ..."
mkdir -p "${SONARQUBE_PLUGINS_DIR}"
mv "${SONARQUBE_CACHE}/${SONAR_FLUTTER_JAR}" "$SONARQUBE_PLUGINS_DIR"

echo "Clearing the bin ..."
rm -rf -f "$SONARQUBE_CACHE"
