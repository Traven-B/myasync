module Local
  @@local = false

  def self.local=(use_local_bool)
    @@local = use_local_bool
  end

  def self.local?
    @@local
  end
end
