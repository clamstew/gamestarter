require 'mandrill'
require_relative 'event.rb'
require_relative '../gamestarter.rb'

mandrill = Mandrill::API.new 'kNgczOYvhEM7T32NFRHLeg'

def send_attendee_email(email)
  begin
    mandrill = Mandrill::API.new 'YOUR_API_KEY'
    message = {"images"=>
        [{"type"=>"image/png", "name"=>"IMAGECID", "content"=>"ZXhhbXBsZSBmaWxl"}],
     "google_analytics_domains"=>["example.com"],
     "subaccount"=>"customer-123",
     "bcc_address"=>"message.bcc_address@example.com",
     "view_content_link"=>nil,
     "auto_html"=>nil,
     "track_clicks"=>nil,
     "tracking_domain"=>nil,
     "preserve_recipients"=>nil,
     "from_email"=>"message.from_email@example.com",
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
     "from_name"=>"Example Name",
     "subject"=>"example subject",
     "recipient_metadata"=>
        [{"rcpt"=>"recipient.email@example.com", "values"=>{"user_id"=>123456}}],
     "inline_css"=>nil,
     "text"=>"Example text content",
     "metadata"=>{"website"=>"www.example.com"},
     "return_path_domain"=>nil,
     "important"=>false,
     "google_analytics_campaign"=>"message.from_email@example.com",
     "html"=>"<p>Example HTML content</p>",
     "tags"=>["password-resets"],
     "global_merge_vars"=>[{"name"=>"merge1", "content"=>"merge1 content"}],
     "auto_text"=>nil,
     "url_strip_qs"=>nil,
     "to"=>[{"email"=>"recipient.email@example.com", "name"=>"Recipient Name"}]}
    async = false
    ip_pool = "Main Pool"
    send_at = "example send_at"
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
end