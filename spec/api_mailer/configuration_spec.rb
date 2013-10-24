require 'spec_helper'

module ApiMailer
  describe Configuration do
    it "should load configuaration" do
      ApiMailer::Configuration[:setting_1].should == "Hello World!"
    end
  end
end

