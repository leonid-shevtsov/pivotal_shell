require 'fileutils'

module PivotalShell::Commands
  class PivotalShell::Commands::InstallHooks < PivotalShell::Command

    def initialize(options)
    end

    def execute
      unless File.directory?('.git')
        STDERR.puts 'This command must be ran from a Git repository. Can\'t find .git in current path'
      else
        `mkdir -p .git/hooks`

        if hook_exists?('prepare-commit-msg') || hook_exists?('commit-msg')
          STDERR.puts 'You already have a prepare-commit-msg or a commit-msg hook'
        else
          %w(prepare-commit-msg commit-msg).each do |hook|
            FileUtils.cp hook_template_filename(hook), hook_filename(hook)
            FileUtils.chmod 0755, hook_filename(hook)
          end
        end
      end
    end

    def hook_template_filename(name)
      "#{File.dirname(__FILE__)}/../../../hooks/#{name}"
    end

    def hook_filename(name)
      ".git/hooks/#{name}"
    end

    def hook_exists?(name)
      File.exists?(hook_filename(name))
    end
  end
end
