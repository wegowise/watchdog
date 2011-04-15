module Watchdog
  class Error < StandardError
    def initialize(meth, from, to)
      super "#{from} can't add method '#{meth}' to #{to}"
    end
  end
  class ExtendError < Error; end
  class IncludeError < Error; end

  def append_features(mod)
    existing = mod.private_instance_methods + mod.instance_methods
    (existing & self.instance_methods).each do |m|
      raise IncludeError.new(m, self, mod)
    end
    super
  end

  def extend_object(obj)
    self.instance_methods.each do |m|
      raise ExtendError.new(m, self, obj) if obj.respond_to?(m, true)
    end
    super
  end
end
