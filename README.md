# Secure Backup and Restore Tool

## Overview
This project provides secure and automated backup and restore functionality using Bash scripts.

## Features
- Backup directories modified within a specific number of days.
- Encrypt backup files using GPG.
- Restore backups securely.

## Usage

### Backup
```bash
./backup.sh <source_dir> <backup_dir> <encryption_key> <days>

