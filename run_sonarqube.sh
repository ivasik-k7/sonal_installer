#!/usr/bin/env bash

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

# ///
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
