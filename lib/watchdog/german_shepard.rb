module Watchdog
  module GermanShepard
    class << self; attr_accessor :created; end
    self.created = []

    def self.create_guard(meth, obj)
      return if created.include?([meth, obj])
      created << [meth, obj]
      meta = class <<obj; self end
      original = meta.instance_method(meth)
      meta.send(:define_method, meth) do |m|
        Watchdog.guard(self, m)
        original.bind(obj).call(m)
      end
    end

    def self.extend_object(obj)
      if obj.respond_to? :method_added
        create_guard :method_added, obj
      elsif obj.respond_to? :singleton_method_added
        create_guard :singleton_method_added, obj
      else
        super
      end
    end

    [:singleton_method_added, :method_added].each do |m|
      define_method(m) do |meth|
        Watchdog.guard(self, meth)
        super(meth)
      end
    end
  end
end
