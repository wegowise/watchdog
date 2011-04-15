module Watchdog
  def append_features(mod)
    self.instance_methods.each do |m|
      raise "#{self} can't add method '#{m}' to #{mod}" if mod.method_defined? m
    end
    super
  end

  def extend_object(obj)
    self.instance_methods.each do |m|
      raise "#{self} can't add method '#{m}' to #{obj}" if obj.respond_to?(m)
    end
    super
  end
end
