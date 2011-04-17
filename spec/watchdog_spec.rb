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
        existing = Class.new
        lambda { existing.send :include, extensions }.should_not raise_error
      end

      it "raises error if existing public methods conflict" do
        existing = create_methods Class.new, :blah
        lambda { existing.send :include, extensions }.should raise_error(Watchdog::MethodExistsError, /#blah/)
      end

      it "raises error if existing private methods conflict" do
        existing = create_methods Class.new, :blah
        existing.send :private, :blah
        lambda { existing.send :include, extensions }.should raise_error(Watchdog::MethodExistsError)
      end
    end

    context "new method" do
      it "doesn't raise error if it doesn't redefine extension methods" do
        existing = Class.new.send :include, extensions
        lambda { existing.send(:define_method, :bling) { } }.should_not raise_error
      end

      it "raises error if it redefines extension methods" do
        existing = Class.new.send :include, extensions
        lambda {
          existing.send(:define_method, :blah) { }
        }.should raise_error(Watchdog::ExtensionMethodExistsError)
      end

      it "raises error if it redefines extension methods for module with method_added" do
        existing = Class.new { def self.method_added(meth); end }.send :include, extensions
        lambda {
          existing.send(:define_method, :blah) { }
        }.should raise_error(Watchdog::ExtensionMethodExistsError)
      end
    end

    it "doesn't guard if subclass of extended class" do
      existing = Class.new.send :include, extensions
      subclass = Class.new(existing)
      lambda { subclass.send(:define_method, :blah) { } }.should_not raise_error
    end

    it "creates one method_added guard per extended class" do
      Watchdog::GermanShepard.created = []
      existing = Class.new { def self.method_added(meth); end }.send :include, extensions
      another_extensions = Module.new.extend(Watchdog)
      existing.send :include, another_extensions
      Watchdog::GermanShepard.created.size.should == 1
    end
  end
end
