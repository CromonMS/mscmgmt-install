# frozen_string_literal: true
require 'aws-sdk'
require 'mail'
require 'dotenv/load'

# 2.4.0 (main):0 > load 'db_backup.rb'
# => true
# 2.4.0 (main):0 > db = DbBackup.new
# => #<DbBackup:0x000000009cb058>
# 2.4.0 (main):0 > db.backup_database
# => ""
# 2.4.0 (main):0 > db.upload_file
# => true
# 2.4.0 (main):0 >
# 2.4.0 (main):0 > db.logs
# => [
#   [0] "LOG: set database to mscmgmt_development",
#   [1] "LOG: set pg_dump binary to /usr/bin/pg_dump",
#   [2] "LOG: backing up @database to @local_path",
#   [3] "LOG: uploading @local_path to s3 backup"
# ]
# 2.4.0 (main):0 >

# specific PG backup script
class DbBackup
  attr_reader :filename, :local_path, :pgdump, :database, :s3, :logs

  def initialize
    @logs = []
    set_database
    set_pgdump_binary
    set_username
    set_db_username
    @s3 = Aws::S3::Resource.new
    @bucket = ENV['S3_BUCKET']
    @filename = "#{Time.now.to_s.split(' ').first}_#{@database}_dump.sql"
    @local_path = "/home/#{@username}/backups/#{@filename}"
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

  Aws.config.update({
                      access_key_id: ENV['S3_ACCESS_KEY_ID'],
                      secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
                      region: ENV['S3_REGION']
                    })
end
#
# puts db = DbBackup.new
# puts db.backup_database
# puts db.upload_file
# puts db.logs
