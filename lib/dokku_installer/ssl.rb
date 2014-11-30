module DokkuInstaller
  class Cli < Thor

    desc "ssl:add CRT KEY", "Add an SSL endpoint."
    def ssl_add(*args)
      key = nil
      certificate = nil
      intermediate_certificates = []

      args.each do |arg|
        file_contents = File.read(arg)
        if file_contents.include?("KEY")
          key = file_contents
        elsif file_contents.include?("BEGIN CERTIFICATE")
          certificate = file_contents
        elsif file_contents.include?("NEW CERTIFICATE REQUEST")
          intermediate_certificates << file_contents
        end
      end

      if key.nil?
        puts "Missing SSL private key.\nSpecify the key, certificate, and any intermediate certificates."
        exit
      elsif certificate.nil?
        puts "Missing SSL certificate.\nSpecify the key, certificate, and any intermediate certificates."
        exit
      end

      puts "Adding SSL private key..."
      command = "echo \"#{key}\" | ssh dokku@#{domain} ssl:key #{app_name}"
      result = `#{command}`

      puts "Adding SSL certificate..."
      combined_certificate = certificate
      if intermediate_certificates.length > 0
        combined_certificate += "#{intermediate_certificates.join("\n")}\n"
      end
      command = "echo \"#{combined_certificate}\" | ssh dokku@#{domain} ssl:certificate #{app_name}"
      exec(command)
    end

    desc "ssl:force DOMAIN", "Force SSL on the given domain."
    def ssl_force(domain = nil)
      if domain.nil?
        puts "Specify a domain to force SSL."
        exit
      end

      run_command "ssl:force #{app_name} #{domain}"
    end

    desc "ssl:remove", "Remove an SSL endpoint."
    def ssl_remove
      run_command "ssl:delete #{domain} #{app_name}"
    end

  end
end
