# Sync media files from local to external drive

```sh
bash rsync_media_files.sh /media/sda3 dry-run
```

This command will sync files and folders from ~/media to /media/sda3/media folder. Then uses verify_sync_fast.sh to check if all the files from local PC are located in the given external drive.
