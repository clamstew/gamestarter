require 'rubygems'
require 'bundler/setup'
require 'debugger'
require 'unirest'
require 'json'
require 'gmail'

module GameStarter
  
  class Event 
    attr_accessor :creator, :time, :deadline, :event_name, :location, :attendees, :minimum, :maximum, :invitees
    
    def initialize (event_time, deadline, event_name, event_location, minimum_attendees, maximum_attendees, creator_name, phone, email, invitees)
      @creator = GameStarter::Creator.new(creator_name, phone, email)
      @event_time = event_time
      @deadline = deadline
      @event_name = event_name
      @event_location = event_location
      @attendees = [] # this will be num attendees with .count
      @minimum_attendees = minimum_attendees
      @maximum_attendees = maximum_attendees
      @create_date = Time.now()
      @modify_date = Time.now()
      @invitees = populate_invitee_array(invitees)
      @invitees = @invitees.collect{|x| x.strip}
    end

    # MIGHT BE COVERED IN THE INITIALIZE FUNCTION
    # def add_attendees (attendees_array)
    #   attendees_array.each do |x|
    #     @attendees << x
    #   end
    # end
    def add_to_firebase
      new_event = {
        creator: {
          name: @creator.name,
          phone: @creator.phone,
          email: @creator.email
        },
        time: @event_time,
        deadline: @deadline, 
        event_name: @event_name, 
        location: @event_location, 
        attendees: [], #@attendees,
        minimum: @minimum_attendees, 
        maximum: @maximum_attendees,
        create_date: @create_date,
        modify_date: @modify_date
      }
      new_event = new_event.to_json

      response = Unirest::post "https://gamestarter.firebaseio.com/events.json",
        { "Accept" => "application/json" }, new_event
    end

    def send_invite_email_to_attendees email
      @attendees.each do |attendee|
        
      end
      # might just call send email message on whole array ??? 
    end

    def send_if_game_on_or_off
      # logic that looks at datetime and returns on if
      #  current time is not past date time
    end

    private 

      # Use this to house all the API logic for Mandrill or Gmail
      #
      # emails - The Array of email addresses
      # 
      # returns true or false if emails are send or not
      def send_email_message email_array
        # mandrill logic (hopefully on an array)
        # return true or false
      end

      def populate_invitee_array(invitees)
        @invitees = invitees.split(',')
      end

  end

  class Creator
    attr_accessor :name, :phone, :email
    def initialize name, phone, email
      @name = name
      @phone = phone
      @email = email
      # @attending = attending 
    end

    def format_email

      
    end

  end

  class Attendee
    attr_accessor :email
    def initialize email
      @email = email
      @attending = false 
    end

    def attending_reply 
      @attending = true
    end

    def get_event_from_firebase(id)
      # id = "-J41ONHpHKmFRknPIpIP"
      response = Unirest::get("https://gamestarter.firebaseio.com/events/#{id}.json",
        { "Accept" => "application/json" })
      response_body = response.body
    end

    private

  end

  class Email
    @@username = ENV['GMAILUSER']
    @@password = ENV['GMAILPSWD']

    def send(emails, event_id)
      gmail = Gmail.connect(@@username, @@password)
      emails.each do |recipient|
        # email = gmail.compose do
        #   reply_url = "http://gamestarter.herokuapp.com/reply/#{event_id}/#{recipient}"
        #   text_part do
        #     body "Game Starter. Go to this address in your webaddress: #{reply_url}"
        #   end
        #   html_part do
        #     content_type 'text/html; charset=UTF-8'
        #     body "<h3>Game Starter</h3><p>Are you attending: <a href=" + reply_url + ">I'm In</a></p>"

        #   end
        #   to recipient.strip()
        #   subject "You've Got a New Event!"

        # end
        reply_url = "http://gamestarter.herokuapp.com/reply/#{event_id}/#{recipient.strip()}"
        gmail.deliver do
        # email = gmail.compose do
          text_part do
            body "Game Starter. Go to this address in your webaddress: #{reply_url}"
          end
          html_part do
            content_type 'text/html; charset=UTF-8'
            body "<h3>Game Starter</h3><p>Are you attending: <a href=" + reply_url + ">I'm In</a></p>"
            # body "<p>Text of <em>html</em> message.</p>"
          end
          to recipient.strip()
          subject "You've Got a New Event!"
          # body body
        end
        
      end
      gmail.logout
    end
  end
end