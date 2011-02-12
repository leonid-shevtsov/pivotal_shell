module PivotalShell::Commands
  class PivotalShell::Commands::Reload < PivotalShell::Command
    def initialize(options)
      opts = OptionParser.new do |opts|
        opts.banner = "Completely reload the stories database from Pivotal Tracker"
        
        opts.on_tail('--help', 'Show this help') do
          puts opts
          exit
        end
        opts.parse!(options)
      end
    end

    def execute
      PivotalShell::Configuration.cache.reload
    end
  end
end
