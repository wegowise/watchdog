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
    def self.extend_object(obj)
      if obj.respond_to? :method_added
        Watchdog.create_guard :method_added, obj
      elsif obj.respond_to? :singleton_method_added
        Watchdog.create_guard :singleton_method_added, obj
      end
      super
    end

    [:singleton_method_added, :method_added].each do |m|
      define_method(m) do |meth|
        Watchdog.check(self, meth)
        super(meth)
      end
    end
  end

  def self.check(obj, meth)
    if extensions[obj].instance_methods.map(&:to_sym).include?(meth)
      raise ExtensionMethodExistsError.new(meth, obj, extensions[obj])
    end
  end

  def self.create_guard(meth, obj)
    meta = class <<obj; self end
    original = meta.instance_method(meth)
    meta.send(:define_method, meth) do |m|
      Watchdog.check(self, m)
      original.bind(obj).call(m)
    end
  end

  # Guards extension methods from being overwritten
  def self.guard(extension, extended)
    extensions[extended] = extension
    extended.extend GermanShepard
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
