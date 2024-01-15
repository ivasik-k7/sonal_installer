#!/usr/bin/env bash

# ///
SONAR_HOME="$HOME/.sonar"
SONAR_SCANNER_HOME="$SONAR_HOME/sonarscanner"

if [ $# -eq 0 ]; then
    branch_name="develop"
else
    branch_name="$(echo "$1" | sed 's/origin\///')"
fi

# Check if sonar-scanner is executable
if command -v "${SONAR_SCANNER_HOME}/bin/sonar-scanner" >/dev/null 2>&1; then
    echo "Sonar Scanner is executable. Proceeding with the command."
    bash "${SONAR_SCANNER_HOME}"/bin/sonar-scanner \
        -Dsonar.branch.name="$branch_name"
else
    echo "Sonar Scanner is not executable or not found. Please check the installation."
fi
