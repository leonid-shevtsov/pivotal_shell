module PivotalShell::Commands
  class PivotalShell::Commands::PrepareCommitMsgHook < PivotalShell::Command
    def initialize(options)
      @filename = options.first
      @commit_message = File.read(@filename)
    end

    def execute
      commit_message_lines = @commit_message.split("\n")
      commit_message_without_comments = commit_message_lines.shift(commit_message_lines.find_index{|line| line =~ /^#/} || commit_message_lines.length)
      File.open(@filename, 'w') do |f|
        f.puts commit_message_without_comments.join("\n")
        f.puts stories
        f.puts commit_message_lines.join("\n")
      end
    end

    def stories
      @stories = PivotalShell::Cache::Story.all(:owner => PivotalShell::Configuration.me, :state => %w(unstarted started))
      @stories.map { |story|
        story_id = "[\##{story.id}]"
        "# #{story_id.rjust(13)} #{story.name}"
      }.join("\n")
    end
  end
end
