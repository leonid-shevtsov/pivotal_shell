module PivotalShell::Commands
  class PivotalShell::Commands::InstallHook < PivotalShell::Command
    HOOK_FILENAME = '.git/hooks/commit-msg'

    def initialize(options)
    end

    def execute
      unless File.directory?('.git')
        STDERR.puts 'This command must be ran from a Git repository. Can\'t find .git in current path'
      end
      `mkdir -p .git/hooks`
      if File.exists?(HOOK_FILENAME) 
        STDERR.puts "You already have a commit-msg hook in #{HOOK_FILENAME}"
        puts commit_hook
      else
        File.open(HOOK_FILENAME, 'w') do |f|
          f.puts commit_hook
          f.chmod 0755
        end
      end
    end

    def commit_hook
      <<-EOT
#!/bin/sh
b exec pivotal commit-hook $1
      EOT
    end
  end
end
