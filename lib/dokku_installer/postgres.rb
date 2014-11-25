module DokkuInstaller
  class Cli < Thor

    desc "postgres:backups", "List available PostgreSQL backups"
    def postgres_backups
      command = "ssh -t dokku@#{domain} postgres:backups #{app_name}"
      puts "Running #{command}..."
      backups = `#{command}`
      backups.split("\n").reverse.each_with_index do |line, index|
        number = "#{index + 1}"
        if number.length < 2
          number = " #{number}"
        end
        puts "#{number}. #{line}"
      end
    end

    desc "postgres:backups:create", "Create a new PostgreSQL backup"
    def postgres_backups_create
      run_command "postgres:backups:create #{app_name}"
    end

    desc "postgres:backups:disable", "Disable daily PostgreSQL backups"
    def postgres_backups_disable
      run_command "postgres:backups:disable #{app_name}"
    end

    desc "postgres:backups:download <number>", "Download the numbered PostgreSQL backup"
    def postgres_backups_download(*args)
      number = args.first ? args.first : 1

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
      run_command "postgres:backups:enable #{app_name}"
    end

    desc "postgres:backups:restore:local <number>", "Restore the numbered PostgreSQL backup locally"
    def postgres_backups_restore_local(*args)
      # Download the backup file
      number = args.first ? args.first : 1

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

  private

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
