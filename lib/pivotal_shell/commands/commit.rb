module PivotalShell::Commands
  class PivotalShell::Commands::Commit < PivotalShell::Command
    def initialize(options)
      @message = options[0]
    end

    def execute
      puts 'Doesnt work yet! Sorry.'
      #exit 0 if (message =~ /\[#\d+\]/) || (message =~ /merge/i) # there is already a task ID in the message, or it is a merge

      #input = File.open('/dev/tty', 'r')
      
      #PivotalShell::Configuration.cache.update
    end
  end
end
