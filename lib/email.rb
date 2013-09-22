require 'mandrill'
require 'unirest'
require_relative 'event.rb'
require_relative '../gamestarter.rb'

# mandrill = Mandrill::API.new 'kNgczOYvhEM7T32NFRHLeg'

def send_attendee_email(email)
  begin
    mandrill = Mandrill::API.new ENV['MANDRILL_APIKEY']
    message = {"images"=>
        [{"type"=>"image/png", "name"=>"IMAGECID", "content"=>"ZXhhbXBsZSBmaWxl"}],
     "google_analytics_domains"=>["example.com"],
     "subaccount"=>"customer-123",
     "bcc_address"=>"twsmith89@gmail.com",
     "view_content_link"=>nil,
     "auto_html"=>nil,
     "track_clicks"=>nil,
     "tracking_domain"=>nil,
     "preserve_recipients"=>nil,
     "from_email"=>"TWSMITH89@gmail.com",
     "track_opens"=>nil,
     "headers"=>{"Reply-To"=>"message.reply@example.com"},
     "attachments"=>
        [{"type"=>"text/plain",
            "name"=>"myfile.txt",
            "content"=>"ZXhhbXBsZSBmaWxl"}],
     "merge_vars"=>
        [{"rcpt"=>"recipient.email@example.com",
            "vars"=>[{"name"=>"merge2", "content"=>"merge2 content"}]}],
     "merge"=>true,
     "signing_domain"=>nil,
     "from_name"=>"Gamestarter",
     "subject"=>"Hello World",
     "recipient_metadata"=>
        [{"rcpt"=>"#{email}", "values"=>{"user_id"=>123456}}],
     "inline_css"=>nil,
     "text"=>"Hello World",
     "metadata"=>{"website"=>"gamestarter.herokuapp.com"},
     "return_path_domain"=>nil,
     "important"=>false,
     "google_analytics_campaign"=>"message.from_email@example.com",
     "html"=>"<p>Hello World</p>",
     "tags"=>["password-resets"],
     "global_merge_vars"=>[{"name"=>"merge1", "content"=>"merge1 content"}],
     "auto_text"=>nil,
     "url_strip_qs"=>nil,
     "to"=>[{"email"=>"twsmith89@gmail.com", "name"=>"Taylor Smith"}]}
    async = false
    ip_pool = "Main Pool"
    send_at =""
    result = mandrill.messages.send message, async, ip_pool, send_at
        # [{"status"=>"sent",
        #     "reject_reason"=>"hard-bounce",
        #     "email"=>"recipient.email@example.com",
        #     "_id"=>"abc123abc123abc123abc123abc123"}]
    
  rescue Mandrill::Error => e
    # Mandrill errors are thrown as exceptions
    puts "A mandrill error occurred: #{e.class} - #{e.message}"
    # A mandrill error occurred: Mandrill::UnknownSubaccountError - No subaccount exists with the id 'customer-123'    
    raise

  response = Unirest::post "https://mandrillapp.com/api/1.0//messages/send.json",
    { "Accept" => "application/json" }, message
  end
end