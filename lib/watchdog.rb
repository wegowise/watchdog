module Watchdog
  # Maps objects or modules to their extension modules
  class <<self; attr_accessor :extensions; end
  self.extensions = {}

  class Error < StandardError
    def initialize(meth, from, to)
      super "#{from} can't add method '#{meth}' to #{to}"
    end
  end
  class ExtendError < Error; end
  class IncludeError < Error; end

  module GermanShepard
    [:singleton_method_added, :method_added].each do |m|
      define_method(m) do |meth|
        if Watchdog.extensions[self].instance_methods.include?(meth)
          raise Watchdog::Error.new(meth, self, Watchdog.extensions[self])
        end
        super
      end
    end
  end

  def self.guard(mod, guarded)
    extensions[guarded] = mod
    guarded.extend GermanShepard
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
