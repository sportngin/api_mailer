require 'spec_helper'

class MyMailer < ApiMailer::Base
  def mail_me(options)
    mail(options)
  end
end

module ApiMailer
  describe Base do
    it "should create an instance and call instance method when the calling the class method" do
      MyMailer.any_instance.should_receive :mail_me
      MyMailer.mail_me
    end

    it "should call deliver_message and build_message when you deliver a message" do
      Rails.env.stub(:test?).and_return(false)
      MyMailer.any_instance.should_receive :collect_responses
      message = MyMailer.mail_me(to: "billy@example.com")
      message.should_receive :build_message
      message.should_receive :deliver_message
      message.deliver
    end
  end
end
