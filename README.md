# API Mailer

## The whys

* SMTP is silly, let's use flexibly APIs instead
* It doesn't use the huge, bloated Mail gem
* It doesn't use the huge, bloated SMTP gem
* Its pluggable

## Usage

```ruby
# app/mailers/mailing_base.rb
class MailingBase < ApiMailer::Base
  def build_message
    # This method must be defined, it builds the package for deliver
    # here is an example json object
    headers.extract(:to, :from, :subject).merge(html: responses.html_part.body.to_s).to_json
  end
  
  def deliver_message(message)
    #send the message somewhere using POST or whatever
  end
end

# app/mailers/my_mailer.rb
class MyMailer < MailingBase
  def cool_message_bro(user)
    @user = user
    mail(to: "email_me@example.com", 
         from: "sender@example.com",
         subject: "Cool Message for you, Bro",
         other_header: "value")
  end
end

# app/views/my_mailer/cool_message_bro.html.erb
Cool message, <%= @user.name %>!

# sending mail
MyMailer.cool_message_bro(user).deliver
```

## Configuration

_*Coming Soon!*_

