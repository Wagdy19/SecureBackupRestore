#!/bin/bash

# Source shared library
source "$(dirname "$0")/backup_restore_lib.sh"

validate_backup_params "$@"
backup "$@"

