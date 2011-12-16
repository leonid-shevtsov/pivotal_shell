module PivotalShell::Commands
  class PivotalShell::Commands::PrepareCommitMsgHook < PivotalShell::Command
    def initialize(options)
      @filename = options.first
      @commit_message = File.read(@filename)
    end

    def execute
      File.open(@filename, 'w') do |f|
        f.puts
        f.puts stories
        f.puts @commit_message.lstrip
      end
    end

    def stories
      @stories = PivotalShell::Cache::Story.all(:owner => PivotalShell::Configuration.me, :state => %w(unstarted started))
      @stories.map { |story|
        story_id = "[\##{story.id}]"
        "\# #{story_id.rjust(13)} #{story.name}"
      }.join("\n")
    end
  end
end
