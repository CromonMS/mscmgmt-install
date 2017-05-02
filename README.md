# mscmgmt Instalation notes

This is the top level README for the installation of the mscmgmt catalogue
system

---

### Rake tasks

| Task                  | Description     |
| :-------------        | :------------- |
| rake check_ffmpeg     | # check ffmpeg version
| rake check_imagemagik | # check imagemagik installation
| rake check_postgres   | # check postgres
| rake install          | # run install script
| rake intro            | # intro text
| rake list             | # list all files in directory

---

### db_backup.rb

This script is for running backups on the database.

First make sure you have your Environment variables set, see .env.example. Fill
the fields required, they should be similar to the mscmgmt .env variables so in
the context of mscmgmt installation then you will more than likely have them setup.

This db_backup.rb script should be approached after you have cloned the app and
setup all the relevant databases anyway.

| ENV Variable                 | Description |
| :-------------               | :------------- |
| export S3_BUCKET=            | s3 Bucket Name |
| export S3_REGION=            | s3 Region
| export S3_ACCESS_KEY_ID=     | s3 Access Key ID
| export S3_SECRET_ACCESS_KEY= | s3 Secret Access Key |
| export USERNAME=             | The username used to execute pg_dump * |
| export DB_USERNAME=          | The username for the databse you are backing up * |
| export DB_NAME=              | Database Name * |

\* These ENV variables need to be added to mscmgmt app .env or alternatively you
can use it where the backup script lives.

##### !! Make sure when renaming .env to add it to the .gitignore if it not already added !!

To use the script from the command line and for testing follow these steps
We recommend to use pry, but irb is fine.

```
pry
```

```ruby
load 'db_backup.rb'
db = DbBackup.new
db.backup_database
db.deliver_email
db.logs
```
Or alternatively place the following at the bottom of the file:
```ruby
DbBackup.new.perform!
```
You can now add this script to crontab, just execute
```
ruby /path/to/db_backup.rb
```
