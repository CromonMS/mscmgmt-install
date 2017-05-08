# frozen_string_literal: true
require 'dotenv/load'
require 'aws-sdk'
require 'mail'
require 'colorize'

# TODO: Need to finish the email bit!

# 2.4.0 (main):0 > load 'db_backup.rb'
# => true
# 2.4.0 (main):0 > db = DbBackup.new
# => #<DbBackup:0x000000009cb058>
# 2.4.0 (main):0 > db.backup_database
# => ""
# 2.4.0 (main):0 > db.upload_file
# => true
# 2.4.0 (main):0 > db.deliver_email
# => ""
# 2.4.0 (main):0 > db.logs
# => [
#   [0] "LOG: set database to mscmgmt_development",
#   [1] "LOG: set pg_dump binary to /usr/bin/pg_dump",
#   [2] "LOG: set username to cromon",
#   [3] "LOG: set db username to mscmgmt",
#   [4] "LOG: backing up @database to @local_path",
#   [5] "LOG: uploading @local_path to s3 backup"
#   [6] "LOG: emailed "email" a copy of the database"
# ]
# 2.4.0 (main):0 >

# specific PG backup script
class DbBackup
  attr_reader :filename, :local_path, :pgdump, :database, :s3, :logs, :mail

  def initialize
    @logs = []
    set_database
    set_pgdump_binary
    set_username
    set_db_username
    @s3 = Aws::S3::Resource.new
    @bucket = ENV['S3_BUCKET']
    @timestamp = Time.now.to_s.split(' ').first
    @filename = "#{@timestamp}_#{@database}_dump.sql"
    @local_path = "home/#{@username}/backups/#{@filename}"
  end

  def perform!
    puts Time.now.to_s.red + ' ' + 'Backing Up Database'.green
    backup_database
    puts Time.now.to_s.red + ' ' + 'Uploading Backup to S3'.green
    upload_file
    puts Time.now.to_s.red + ' ' + 'Sending Email with Backup & Logs'.green
    deliver_email @local_path, @logs
    puts Time.now.to_s.red + 'Finished'.green
  end

  def set_database
    @database = ENV['DB_NAME']
    log_events "LOG: set database to #{@database}"
  end

  def set_pgdump_binary
    @pgdump = `which pg_dump`.chomp
    log_events "LOG: set pg_dump binary to #{@pgdump}"
  end

  def set_username
    @username = ENV['USERNAME']
    log_events "LOG: set username to #{@username}"
  end

  def set_db_username
    @db_username = ENV['DB_USERNAME']
    log_events "LOG: set db username to #{@db_username}"
  end

  def backup_database
    log_events "LOG: backed up #{@database} to #{@local_path}"
    `#{@pgdump} -U #{@username} -d #{@database} -f #{@local_path}`
  end

  def create_s3_object
    s3.bucket(@bucket).object(@filename)
  end

  def upload_file
    @file = open @local_path
    if create_s3_object.upload_file(@file)
      log_events "LOG: uploaded #{@local_path} to s3 backup"
    else
      log_events "ERROR: could not upload #{@filename}"
    end
  end

  def log_events(event)
    @logs << event.to_s
  end

  def deliver_email(file, logs)
    log_events 'LOG: emailed e@cromon.co.uk a copy of the database'
    @mail = Mail.deliver do
      to ENV['EMAIL_TO']
      from ENV['EMAIL_FROM']
      subject 'mscmgmt Database Backup'
      body "Attached is the backup for mscmgmt\n Here are the logs: #{logs}"
      add_file file
    end
  end
end

Aws.config.update({
                    access_key_id: ENV['S3_ACCESS_KEY_ID'],
                    secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
                    region: ENV['S3_REGION']
                  })

Mail.defaults do
  delivery_method :smtp,
                  address: 'smtp.gmail.com',
                  port: 587,
                  user_name: ENV['GMAIL_USERNAME'],
                  password: ENV['GMAIL_PASSWORD'],
                  authentication: 'plain',
                  enable_starttls_auto: true
end
