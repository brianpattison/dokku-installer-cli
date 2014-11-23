# Dokku Installer CLI

Command line tool for Dokku Installer.

## Installation

Add this line to your application's Gemfile:

```bash
$ gem install dokku-installer-cli
```

## Usage

```bash
$ dokku help

Commands:
  dokku config                                    # Display the app's environment variables
  dokku config:get KEY                            # Display an environment variable value
  dokku config:set KEY1=VALUE1 [KEY2=VALUE2 ...]  # Set one or more environment variables
  dokku config:unset KEY1 [KEY2 ...]              # Unset one or more environment variables
  dokku domains                                   # Display the app's domains
  dokku domains:set DOMAIN1 [DOMAIN2 ...]         # Set one or more domains
  dokku help [COMMAND]                            # Describe available commands or one specific command
  dokku logs [-t]                                 # Show the last logs for the application (-t follows)
  dokku open                                      # Open the application in your default browser
  dokku postgres:backups                          # List available PostgreSQL backups
  dokku postgres:backups:create                   # Create a new PostgreSQL backup
  dokku postgres:backups:disable                  # Disable daily PostgreSQL backups
  dokku postgres:backups:download <number>        # Download the numbered PostgreSQL backup
  dokku postgres:backups:enable                   # Enable daily PostgreSQL backups
  dokku postgres:backups:restore:local <number>   # Restore the numbered PostgreSQL backup locally
  dokku restart                                   # Restart the application
  dokku run <cmd>                                 # Run a command in the environment of the application
  dokku ssl:certificate <file path>               # Add a signed certificate for SSL (server.crt)
  dokku ssl:key <file path>                       # Add a private key for SSL (server.key)
  dokku url                                       # Show the URL for the application
  dokku version                                   # Show dokku-installer-cli's version
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/dokku_installer_cli/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
