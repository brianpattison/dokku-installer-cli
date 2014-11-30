require "json"
require "net/http"
require "thor"

module DokkuInstaller
  VERSION = "0.1.3"

  class Cli < Thor

    desc "upgrade", "Upgrade the Dokku install on your remote server"
    def upgrade
      command = "ssh -t root@#{domain} \"rm -rf /var/lib/dokku/plugins; cd /root/dokku; git pull origin master; make install\""
      puts "Running #{command}..."
      exec(command)
    end

    desc "update", "Update dokku-installer-cli to latest version"
    def update
      command = "gem install dokku-installer-cli"
      puts "Running #{command}..."
      exec(command)
    end

    desc "version", "Show version information"
    def version
      gem_version = "v#{DokkuInstaller::VERSION}"

      # Grab the latest version of the RubyGem
      rubygems_json = Net::HTTP.get("rubygems.org", "/api/v1/gems/dokku-installer-cli.json")
      rubygems_version = "v#{JSON.parse(rubygems_json)["version"].strip}"

      # Grab the version of the remote Dokku install
      command = "ssh -t dokku@#{domain} version"
      remote_version = `#{command}`.strip

      upgrade_message = ""
      if gem_version != rubygems_version
        upgrade_message = " Run `dokku update` to install"
      end

      puts
      puts "Dokku Installer CLI"
      puts "  Installed: #{gem_version}"
      puts "  Latest:    #{rubygems_version}#{upgrade_message}"
      puts

      upgrade_message = ""
      if remote_version != rubygems_version
        upgrade_message = " Run `dokku upgrade` to install"
      end

      puts "Remote Dokku Version"
      puts "  Installed: #{remote_version}"
      puts "  Latest:    #{rubygems_version}#{upgrade_message}"
      puts
    end

  end
end
