module Watchdog
  # Maps objects or modules to their extension modules
  class <<self; attr_accessor :extensions; end
  self.extensions = {}

  class Error < StandardError
    def initialize(meth, from, to)
      mtype = to.is_a?(Module) ? '#' : '.'
      super self.class::MESSAGE % [from, "#{to}#{mtype}#{meth}"]
    end
  end
  class MethodExistsError < Error
    MESSAGE = "%s not allowed to redefine existing method %s"
  end
  class ExtensionMethodExistsError < Error
    MESSAGE = "%s not allowed to redefine extension method from %s"
  end

  module GermanShepard
    [:singleton_method_added, :method_added].each do |m|
      define_method(m) do |meth|
        if Watchdog.extensions[self].instance_methods.map(&:to_sym).include?(meth)
          raise Watchdog::ExtensionMethodExistsError.new(meth, self, Watchdog.extensions[self])
        end
        super(meth)
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
      raise MethodExistsError.new(m, self, mod)
    end
    super
  end

  def extend_object(obj)
    Watchdog.guard(self, obj)
    self.instance_methods.each do |m|
      raise MethodExistsError.new(m, self, obj) if obj.respond_to?(m, true)
    end
    super
  end
end
