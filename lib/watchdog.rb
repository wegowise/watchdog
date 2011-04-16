require 'watchdog/error'
require 'watchdog/german_shepard'

module Watchdog
  # Maps objects or modules to their extension modules
  class <<self; attr_accessor :extensions; end
  self.extensions = {}

  # Guards extension methods from being overwritten
  def self.guard(obj, meth)
    if extensions[obj].instance_methods.map(&:to_sym).include?(meth)
      raise ExtensionMethodExistsError.new(meth, obj, extensions[obj])
    end
  end

  def self.setup_guard(extension, extended)
    extensions[extended] = extension
    extended.extend GermanShepard
  end

  def append_features(mod)
    Watchdog.setup_guard(self, mod)
    existing = mod.private_instance_methods + mod.instance_methods
    (existing & self.instance_methods).each do |m|
      raise MethodExistsError.new(m, self, mod)
    end
    super
  end

  def extend_object(obj)
    Watchdog.setup_guard(self, obj)
    self.instance_methods.each do |m|
      raise MethodExistsError.new(m, self, obj) if obj.respond_to?(m, true)
    end
    super
  end
end
