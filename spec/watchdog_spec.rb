require 'watchdog'

describe Watchdog do
  def create_methods(obj, *meths)
    obj_class = obj.is_a?(Module) ? obj : class << obj; self; end
    meths.each {|e| obj_class.send(:define_method, e) {} }
    obj
  end

  context "when extended" do
    let(:extensions) { create_methods Module.new.extend(Watchdog), :blah }

    context "new extension method" do
      it "doesn't raise error if no existing methods conflict" do
        existing = Object.new
        lambda { existing.extend extensions }.should_not raise_error
      end

      it "raises error if existing public methods conflict" do
        existing = create_methods Object.new, :blah
        lambda { existing.extend extensions }.should raise_error(Watchdog::MethodExistsError, /\.blah/)
      end

      it "raises error if existing private methods conflict" do
        existing = create_methods Object.new, :blah
        class <<existing; self.send :private, :blah; end
        lambda { existing.extend extensions }.should raise_error(Watchdog::MethodExistsError)
      end
    end

    context "new method" do
      it "doesn't raise error if it doesn't redefine extension methods" do
        existing = Object.new.extend extensions
        lambda { def existing.bling; end }.should_not raise_error
      end

      it "raises error if it redefines extension methods" do
        existing = Object.new.extend extensions
        lambda { def existing.blah; end }.should raise_error(Watchdog::ExtensionMethodExistsError)
      end

      it "raises error if it redefines extension methods for object with singleton_method_added" do
        existing = Object.new
        def existing.singleton_method_added(meth); end
        existing.extend extensions
        lambda { def existing.blah; end }.should raise_error(Watchdog::ExtensionMethodExistsError)
      end
    end
  end

  context "when included" do
    let(:extensions) { create_methods Module.new.extend(Watchdog), :blah }

    context "new extension method" do
      it "doesn't raise error if no existing methods conflict" do
        existing = Module.new
        lambda { existing.send :include, extensions }.should_not raise_error
      end

      it "raises error if existing public methods conflict" do
        existing = create_methods Module.new, :blah
        lambda { existing.send :include, extensions }.should raise_error(Watchdog::MethodExistsError, /#blah/)
      end

      it "raises error if existing private methods conflict" do
        existing = create_methods Module.new, :blah
        existing.send :private, :blah
        lambda { existing.send :include, extensions }.should raise_error(Watchdog::MethodExistsError)
      end
    end

    context "new method" do
      it "doesn't raise error if it doesn't redefine extension methods" do
        existing = Module.new.send :include, extensions
        lambda { existing.send(:define_method, :bling) { } }.should_not raise_error
      end

      it "raises error if it redefines extension methods" do
        existing = Module.new.send :include, extensions
        lambda {
          existing.send(:define_method, :blah) { }
        }.should raise_error(Watchdog::ExtensionMethodExistsError)
      end

      it "raises error if it redefines extension methods for module with method_added" do
        existing = Module.new { def self.method_added(meth); end }
        existing.send :include, extensions
        lambda {
          existing.send(:define_method, :blah) { }
        }.should raise_error(Watchdog::ExtensionMethodExistsError)
      end
    end
  end
end
