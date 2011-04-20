require 'watchdog/error'
require 'watchdog/german_shepard'
require 'watchdog/version'

module Watchdog
  class <<self; attr_accessor :extensions, :subclasses, :sleep; end
  self.extensions, self.subclasses = {}, []
  # sleep when rspec mocks redefine guarded methods
  self.sleep = lambda { defined? RSpec && !caller.grep(/rspec-mocks/).empty? }

  # Guards extension methods from being overwritten
  def self.guard(obj, meth)
    return if subclasses.include?(obj) || (sleep && sleep.call)
    return subclasses << obj if !extensions.key?(obj) && extensions.keys.
      any? {|e| e.is_a?(Module) && e > obj }
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
