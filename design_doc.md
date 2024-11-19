
#### **design_doc.md**
```markdown
# Design Document

## Assumptions
- `tar`, `gpg`, and `scp` are installed.
- SSH access to the remote server is configured.

## Structure
- `backup.sh`: Main backup script.
- `restore.sh`: Main restore script.
- `backup_restore_lib.sh`: Library with shared functions.

## Workflow
- **Backup**:
  1. Validate inputs.
  2. Compress and encrypt modified directories.
  3. Copy backup to a remote server.

- **Restore**:
  1. Validate inputs.
  2. Decrypt and extract files.

## Enhancements
- Modularized functions for reuse.
- Automated daily backups using cron jobs.

