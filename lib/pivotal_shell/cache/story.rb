class PivotalShell::Cache
  class Story
    ATTRIBUTES=%w(requested_by_id name id current_state accepted_at labels url estimate description created_at owned_by_id story_type)
    
    ATTRIBUTES.each do |attribute|
      attr_reader attribute
    end

    def initialize(source={})
      if source.is_a? PivotalTracker::Story
        raise 'TODO'
      elsif source.is_a? Hash
        create_from_hash(source)
      end
    end

    def self.find(id)
      hash = PivotalShell::Configuration.cache.db.execute("SELECT * FROM stories WHERE id=?", id).first
      hash && new(hash)
    end

    def owned_by
      return nil if owned_by_id.nil?
      @owned_by ||= PivotalShell::Cache::User.find(owned_by_id)
    end

    def requested_by
      return nil if requested_by_id.nil?
      @requested_by ||= PivotalShell::Cache::User.find(requested_by_id)
    end

  protected
    def create_from_hash(hash)
      PivotalShell::Cache::Story::ATTRIBUTES.each do |attribute|
        self.instance_variable_set("@#{attribute}", hash[attribute])
      end
    end
  end
end
