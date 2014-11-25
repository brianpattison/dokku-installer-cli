module DokkuInstaller
  class Cli < Thor

    desc "domains", "Display the app's domains"
    def domains(*args)
      run_command "domains #{app_name}"
    end

    desc "domains:set DOMAIN1 [DOMAIN2 ...]", "Set one or more domains"
    def domains_set(*args)
      run_command "domains:set #{app_name} #{args.join(' ')}"
    end

  end
end
