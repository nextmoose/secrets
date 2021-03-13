## To create an image
1. On the creator machine.
   1. Use rpi-imager to burn ubuntu 20 to the sd-card
   2. Execute `ubuntu-10` to copy this code onto the sd-card.
2. On the install machine
   1. Boot it up using the previously created card.
   2. Follow the install process.  (Will take a while)
   3. When it is ready for use, open a terminal to the /wizardry directory and execute `./ubuntu.sh` (Will take a while - about 5 minutes)
   4. When that is done.  close the terminal and open a new terminal to the /wizardry directory and execute `direnv allow .`  (Will take a while - about 5 minutes)
   5. Execute `initial-configuration` (should not take long but requires manually inputting a passphrase)
   6. To verify execute `browser-pass show` and then use browser-pass to show a secret.  This should work.

## To backup an image
Run `ubuntu-backup`.  This will create a cronjob that will continuously test if
1. the backup process is not already running (and the restore process is not running)
2. there is an /dev/sda to backup
3. there is no manual lock
4. the system load is light
If all those conditions are met, it will backup /dev/sda.
After backing it up, it will hash the backup file.
Then it will compare the hash and file to the most penultimate backup.  If they are the same, it will delete the ultimate backup.
Ideally, consecutive backups should be identical and it just keeps the oldest.

## To restore an image
Run `ubuntu-restore`.