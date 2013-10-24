# API Mailer

## The whys

* SMTP is silly, let's use flexibly APIs instead
* It doesn't use the huge, bloated Mail gem
* It doesn't use the huge, bloated SMTP gem
* Its pluggable

## Usage

```ruby
# app/mailers/my_mailer.rb
class MyMailer < ApiMailer::Base
  def cool_message_bro(user)
    @user = user
  end
end

# app/views/my_mailer/cool_message_bro.html.erb
Cool message, <%= @user.name %>!
```

## Configuration

_*Coming Soon!*_
