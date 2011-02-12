module PivotalShell::Commands
  class PivotalShell::Commands::Update < PivotalShell::Command
    def initialize(options)
      opts = OptionParser.new do |opts|
        opts.banner = "Update the stories database from Pivotal Tracker"
        
        opts.on_tail('--help', 'Show this help') do
          puts opts
          exit
        end
        opts.parse!(options)
      end
    end

    def execute
      PivotalShell::Configuration.cache.refresh
    end
  end
end
