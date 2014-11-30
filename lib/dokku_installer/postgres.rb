module DokkuInstaller
  class Cli < Thor

    desc "postgres:backups", "List available PostgreSQL backups as a numbered list"
    def postgres_backups
      command = "ssh -t dokku@#{domain} postgres:backups #{app_name}"
      puts "Running #{command}..."
      backups = `#{command}`
      backups.split("\n").select{|backup| backup != "" }.reverse.each_with_index do |line, index|
        number = "#{index + 1}"
        if number.length < 2
          number = " #{number}"
        end
        puts "[#{number}] #{line}"
      end
    end

    desc "postgres:backups:create", "Create a new PostgreSQL backup"
    def postgres_backups_create
      command = "ssh -t dokku@#{domain} postgres:backups:create #{app_name}"
      puts "Running #{command}..."
      result = `#{command}`

      if result.include?("database dumped")
        puts "Database backup created successfully."
      else
        puts "Database backup could not be created."
      end
    end

    desc "postgres:backups:disable", "Disable daily PostgreSQL backups"
    def postgres_backups_disable
      run_command "postgres:backups:disable #{app_name}"
    end

    desc "postgres:backups:download <number>", "Download the numbered PostgreSQL backup"
    def postgres_backups_download(number = nil)
      number ||= 1

      if backup = backup_filename(number)
        command = "postgres:backups:download #{app_name} #{backup} > #{backup}"
        puts "Saving to local file: #{backup}"
        run_command(command)
      else
        puts "Invalid backup number"
      end
    end

    desc "postgres:backups:enable", "Enable daily PostgreSQL backups"
    def postgres_backups_enable
      command = "ssh -t root@#{domain} \"dokku postgres:backups:enable #{app_name} && service cron restart\""
      puts "Running #{command}..."
      exec(command)
    end

    desc "postgres:backups:restore <number>", "Restore a numbered PostgreSQL backup"
    def postgres_backups_restore(number = nil)
      if number.nil?
        puts "You must specify a numbered backup."
        exit
      end

      if backup = backup_filename(number)
        command = "postgres:backups:restore #{app_name} #{backup}"
        run_command(command)
      else
        puts "Invalid backup number"
      end
    end

    desc "postgres:backups:restore:local <number>", "Restore a numbered PostgreSQL backup locally"
    def postgres_backups_restore_local(number = nil)
      # Download the backup file
      number ||= 1

      if backup = backup_filename(number)
        command = "ssh -t dokku@#{domain} postgres:backups:download #{app_name} #{backup} > #{backup}"
        puts "Saving to local file: #{backup}"
        `#{command}`

        if psql_options
          command = "psql #{psql_options} --file=#{backup}"
          puts "Running #{command}..."
          `#{command}`
          puts "Deleting #{backup}..."
          `rm #{backup}`
        end
      else
        puts "Invalid backup number"
      end
    end

    desc "postgres:export <file.sql>", "Export Postgres data to local file"
    def postgres_export(file = "export.sql")
      command = "postgres:dump #{app_name} > #{file}"
      run_command(command)
    end

    desc "postgres:import <file.sql>", "Restore database data from a local file"
    def postgres_import(file)
      command = "postgres:restore #{app_name} < #{file}"
      run_command(command)
    end

  private

    def backup_filename(number)
      # Make sure the number is valid or use 1
      number = number.to_s.gsub(/\D/, "").to_i
      number = 1 if number < 1

      # Get the file name for the numbered backup
      puts "Getting list of backups..."
      command = "ssh -t dokku@#{domain} postgres:backups #{app_name}"
      backups = `#{command}`
      index = number - 1
      if filename = backups.split("\n").select{|backup| backup != "" }.reverse[index]
        filename.strip
      else
        nil
      end
    end

    def psql_options
      @psql_options ||= begin
        restore_options = nil

        if File.exist?("./config/database.yml")
          if development_config = YAML::load(IO.read("./config/database.yml"))["development"]
            restore_options = "--host=#{development_config['host']} --dbname=#{development_config['database']}"

            if username = development_config["username"]
              restore_options += " --username=#{username}"
            end

            if port = development_config["port"]
              restore_options += " --port=#{port}"
            end
          else
            puts "Missing database.yml config for development environment"
          end
        else
          puts "Missing file config/database.yml"
        end

        restore_options
      end
    end

  end
end
