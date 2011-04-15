require 'watchdog'

describe Watchdog do
  def create_methods(obj, *meths)
    obj_class = obj.is_a?(Module) ? obj : class << obj; self; end
    meths.each {|e| obj_class.send(:define_method, e) {} }
    obj
  end

  context "when extended" do
    let(:safe_module) { create_methods Module.new.extend(Watchdog), :blah }

    it "doesn't raise error if no methods conflict" do
      existing = Object.new
      lambda { existing.extend safe_module }.should_not raise_error
    end

    it "does raise error if methods conflict" do
      existing = create_methods Object.new, :blah
      lambda { existing.extend safe_module }.should raise_error
    end
  end

  context "when included" do
    let(:safe_module) { create_methods Module.new.extend(Watchdog), :blah }

    it "doesn't raise error if no methods conflict" do
      existing = Module.new
      lambda { existing.send :include, safe_module }.should_not raise_error
    end

    it "does raise error if methods conflict" do
      existing = create_methods Module.new, :blah
      lambda { existing.send :include, safe_module }.should raise_error
    end
  end
end
