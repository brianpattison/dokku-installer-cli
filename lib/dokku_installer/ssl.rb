module DokkuInstaller
  class Cli < Thor

    # certs:add CRT KEY            #  Add an ssl endpoint to an app.
    # certs:chain CRT [CRT ...]    #  Print the ordered and complete chain for the given certificate.
    # certs:info                   #  Show certificate information for an ssl endpoint.
    # certs:key CRT KEY [KEY ...]  #  Print the correct key for the given certificate.
    # certs:remove                 #  Remove an SSL Endpoint from an app.
    # certs:rollback               #  Rollback an SSL Endpoint for an app.
    # certs:update CRT KEY         #  Update an SSL Endpoint on an app.

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
    def ssl_force(*args)
      domain = args.first
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
