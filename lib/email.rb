require 'mandrill'
require 'unirest'
require_relative 'event.rb'
require_relative '../gamestarter.rb'

# mandrill = Mandrill::API.new 'kNgczOYvhEM7T32NFRHLeg'

def send_attendee_email(email)
  m = Mandrill::API.new
    message = {  
     :subject=> "Hello from the Mandrill API",  
     :from_name=> "Your name",  
     :text=>"Hi message, how are you?",  
     :to=>[  
       {  
         :email=> "#{email}",  
         :name=> "Recipient1"  
       }  
     ],  
     :html=>"<html><h1>Hi <strong>message</strong>, how are you?</h1></html>",  
     :from_email=>"sender@yourdomain.com"  
    }  
    sending = m.messages.send message  
    puts sending

  response = Unirest::post "https://mandrillapp.com/api/1.0//messages/send.json",
    { "Accept" => "application/json" }, message
end
