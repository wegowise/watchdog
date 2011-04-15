module Watchdog
  class Error < StandardError
    def initialize(meth, from, to)
      super "#{from} can't add method '#{meth}' to #{to}"
    end
  end
  class ExtendError < Error; end
  class IncludeError < Error; end

  def self.guard(mod, guarded)
    guard_mod = Module.new { class << self; attr_accessor :existing; end }
    guard_mod.existing = mod
    guard_meth = guarded.is_a?(Module) ? :method_added : :singleton_method_added
    guard_mod.send(:define_method, guard_meth) do |meth|
      if guard_mod.existing.instance_methods.include?(meth)
        raise Watchdog::Error.new(meth, self, mod)
      end
      super
    end
    guarded.extend guard_mod
  end

  def append_features(mod)
    Watchdog.guard(self, mod)
    existing = mod.private_instance_methods + mod.instance_methods
    (existing & self.instance_methods).each do |m|
      raise IncludeError.new(m, self, mod)
    end
    super
  end

  def extend_object(obj)
    Watchdog.guard(self, obj)
    self.instance_methods.each do |m|
      raise ExtendError.new(m, self, obj) if obj.respond_to?(m, true)
    end
    super
  end
end
