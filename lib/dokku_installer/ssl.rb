module DokkuInstaller
  class Cli < Thor

    desc "ssl:certificate <file path>", "Add a signed certificate for SSL (server.crt)"
    def ssl_certificate(*args)
      file_path = args.first
      file_contents = File.read(file_path)
      command = "echo \"#{file_contents}\" | ssh dokku@#{domain} ssl:certificate #{app_name}"

      puts "Running #{command}..."
      exec(command)
    end

    desc "ssl:key <file path>", "Add a private key for SSL (server.key)"
    def ssl_key(*args)
      file_path = args.first
      file_contents = File.read(file_path)
      command = "echo \"#{file_contents}\" | ssh dokku@#{domain} ssl:key #{app_name}"

      puts "Running #{command}..."
      exec(command)
    end

  end
end
