#!/bin/bash

# Validate Backup Parameters
validate_backup_params() {
    if [ "$#" -ne 4 ]; then
        echo "Error: Invalid number of parameters for backup!"
        echo "Usage: backup.sh <source_dir> <backup_dir> <encryption_key> <days>"
        exit 1
    fi

    if [ ! -d "$1" ]; then
        echo "Error: Source directory does not exist!"
        exit 1
    fi

    if [ ! -d "$2" ]; then
        echo "Error: Backup directory does not exist!"
        exit 1
    fi

    if [[ ! "$4" =~ ^[0-9]+$ ]]; then
        echo "Error: Days parameter must be a positive integer!"
        exit 1
    fi
}

# Backup Functionality
backup() {
    local source_dir="$1"
    local backup_dir="$2"
    local encryption_key="$3"
    local days="$4"
    local date_stamp=$(date +"%Y-%m-%d_%H-%M-%S")
    local temp_backup_dir="${backup_dir}/${date_stamp}"

    mkdir -p "$temp_backup_dir"

    for dir in "$source_dir"/*; do
        if [ -d "$dir" ]; then
            local dir_name=$(basename "$dir")
            local archive_name="${temp_backup_dir}/${dir_name}_${date_stamp}.tar.gz"
            
            # Backup files modified within 'n' days
            find "$dir" -type f -mtime -"$days" | tar -czf "$archive_name" -T -
            
            # Encrypt archive
            gpg --yes --batch --passphrase "$encryption_key" -c "$archive_name"
            rm "$archive_name"
        fi
    done

    # Combine all encrypted files into a single tar
    tar -cf "${temp_backup_dir}/full_backup_${date_stamp}.tar" "${temp_backup_dir}"/*.gpg
    gzip "${temp_backup_dir}/full_backup_${date_stamp}.tar"
    gpg --yes --batch --passphrase "$encryption_key" -c "${temp_backup_dir}/full_backup_${date_stamp}.tar.gz"
    rm "${temp_backup_dir}/full_backup_${date_stamp}.tar.gz"
    
    scp "${temp_backup_dir}/full_backup_${date_stamp}.tar.gz.gpg" user@remote_server:/path/to/backup/
}

# Validate Restore Parameters
validate_restore_params() {
    if [ "$#" -ne 3 ]; then
        echo "Error: Invalid number of parameters for restore!"
        echo "Usage: restore.sh <backup_dir> <restore_dir> <decryption_key>"
        exit 1
    fi

    if [ ! -d "$1" ]; then
        echo "Error: Backup directory does not exist!"
        exit 1
    fi

    if [ ! -d "$2" ]; then
        echo "Error: Restore directory does not exist!"
        exit 1
    fi
}

# Restore Functionality
restore() {
    local backup_dir="$1"
    local restore_dir="$2"
    local decryption_key="$3"
    local temp_dir="${restore_dir}/temp"

    mkdir -p "$temp_dir"

    for file in "$backup_dir"/*.gpg; do
        gpg --yes --batch --passphrase "$decryption_key" -d "$file" > "${temp_dir}/$(basename "$file" .gpg)"
    done

    for archive in "${temp_dir}"/*.tar.gz; do
        tar -xzf "$archive" -C "$restore_dir"
    done

    rm -rf "$temp_dir"
}

