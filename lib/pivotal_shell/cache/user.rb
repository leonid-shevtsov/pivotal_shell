class PivotalShell::Cache
  class User
    ATTRIBUTES=%w(name id initials email)
    
    ATTRIBUTES.each do |attribute|
      attr_reader attribute
    end
    
    def initialize(source={})
      if source.is_a? PivotalTracker::Membership
        raise 'TODO'
      elsif source.is_a? Hash
        create_from_hash(source)
      end
    end

    def to_s
      name
    end
    
    def self.find(id)
      hash = PivotalShell::Configuration.cache.db.execute("SELECT * FROM users WHERE id=? OR initials=? OR name=? OR email=?", id, id, id, id).first
      hash && new(hash)
    end

  protected
    def create_from_hash(hash)
      PivotalShell::Cache::User::ATTRIBUTES.each do |attribute|
        self.instance_variable_set("@#{attribute}", hash[attribute])
      end
    end
  end
end
