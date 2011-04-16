module Watchdog
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
end
