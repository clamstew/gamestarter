require 'rubygems'
require 'bundler/setup'
require 'debugger'
require 'unirest'
require 'json'
require 'gmail'
require 'mandrill'

module GameStarter
  
  class Event 
    attr_accessor :creator, :event_time, :deadline, :event_name, :event_location, :attendees, :minimum_attendees, :maximum_attendees, :invitees
    
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
        minimum: @minimum_attendees.to_i, 
        maximum: @maximum_attendees.to_i,
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

      # Check to see if the deadline for a given event has passed.
      # If it has, return true.
      # If not, return false.
      # To be used in the cron job.
      def has_deadline_passed?
        if Time.now > @deadline return true
        else return false
      end

      # Checks to see if the minimum number of people has been reached for a given event.
      # If it has, return true.
      # If not, return false.
      # To be used in the cron job. Could also be used in email logic?
      def is_minimum_reached?
        if @attendees.count >= @minimum_attendees return true
        else return false
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
    attr_accessor :email, :attending
    def initialize email
      @email = email
      @attending = false 
    end

    # When a user opts in to the event, set attending to true
    def accept_invitation
      @attending = true
    end

    # Grab event data from Firebase.
    # id is a string argument that represents the location of the event needed.
    # Returns response_body, a json object.
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
    
    def send_game_on(emails, event_id)
      gmail = Gmail.connect(@@username, @@password)
      emails.each do |recipient|
        reply_url = "http://gamestarter.herokuapp.com/reply/#{event_id}/#{recipient.strip()}"
        gmail.deliver do
        # email = gmail.compose do
          text_part do
            body "Game on for this game: ______"
          end
          html_part do
            content_type 'text/html; charset=UTF-8'
            body "<h3>Game Starter</h3><h3>Game Is On</h3><p>You are In.</p>"
            # body "<p>Text of <em>html</em> message.</p>"
          end
          to recipient.strip()
          subject "Game On! | game > starter"
          # body body
        end
        
      end
      gmail.logout
    end

    def send_game_already_on(email, event_id)
      gmail = Gmail.connect(@@username, @@password)
      reply_url = "http://gamestarter.herokuapp.com/reply/#{event_id}/#{recipient.strip()}"
      gmail.deliver do
      # email = gmail.compose do
        text_part do
          body "Game on for this game: ______"
        end
        html_part do
          content_type 'text/html; charset=UTF-8'
          body "<h3>Game Starter</h3><h3>Game Is On</h3><p>You are In.</p>"
          # body "<p>Text of <em>html</em> message.</p>"
        end
        to email.strip()
        subject "Game On! | game > starter"
        # body body
      end
      gmail.logout
    end

    def send_game_rejection(email, event_id)
      gmail = Gmail.connect(@@username, @@password)
      reply_url = "http://gamestarter.herokuapp.com/reply/#{event_id}/#{recipient.strip()}"
      gmail.deliver do
      # email = gmail.compose do
        text_part do
          body "Game full there are too many people.  The maximum is reached."
        end
        html_part do
          content_type 'text/html; charset=UTF-8'
          body "<h3>Game Starter</h3><h3>Too many people have replied.</h3><p>Catch you next time.</p>"
          # body "<p>Text of <em>html</em> message.</p>"
        end
        to email.strip()
        subject "Game Full | game > starter"
        # body body
      end
      gmail.logout
    end
  end

  class MandrillEmail
    # Sends initial invite to potential attendees
    #
    #
    def send_are_you_in(emails, event_id, event_name)
      mandrill_to_array = []
      mandrill_mergevars_array =[]
      emails.each do |email|
        email_url_encode = email.gsub("@", "%40")
        this_to_object = {
          :email => "#{email}",
          :name => ""
        }
        mandrill_to_array.push(this_to_object)

        this_merge_vars = {
          :rcpt => "#{email}",
          :vars => [
            {
              "name"=> "urlemail",
              "content"=> "#{email}"
            }, 
            {
              "name"=> "replyurl",
              "content"=> "http://gamestarter.herokuapp.com/reply/#{event_id}/#{email_url_encode.strip()}"
            }
          ]
        }
        mandrill_mergevars_array.push(this_merge_vars)
      end

      m = Mandrill::API.new
      message = {  
       :merge_vars => mandrill_mergevars_array,
       :merge => true,
       :subject=> "New Event on GameStarter",  
       :from_name=> "GameStarter <noreply@eventstarter.co>",  
       :text=>"You have a new gamestarter event. Are you in?",  
       :to=> mandrill_to_array,  
       :html=>"<html><h2>Event Name: #{event_name}<p>Yes, <a href=" + '"*|REPLYURL|*"' + ">I'm in!</a></p></h2></html>",  
       :from_email=>"sender@gamestarter.herokuapp.com"  
      }  
      sending = m.messages.send message  
      sending
    end

    # Sends the Game On email - if minimum has been met before deadline
    #
    #
    def send_game_on(emails, event_id, event_name)
      mandrill_to_array = []
      # mandrill_mergevars_array =[]
      emails.each do |email|
        # email_url_encode = email.gsub("@", "%40")
        this_to_object = {
          :email => "#{email}",
          :name => ""
        }
        mandrill_to_array.push(this_to_object)

        # this_merge_vars = {
        #   :rcpt => "#{email}",
        #   :vars => [
        #     {
        #       "name"=> "urlemail",
        #       "content"=> "#{email}"
        #     }, 
        #     {
        #       "name"=> "replyurl",
        #       "content"=> "http://gamestarter.herokuapp.com/reply/#{event_id}/#{email_url_encode.strip()}"
        #     }
        #   ]
        # }
        # mandrill_mergevars_array.push(this_merge_vars)
      end

      m = Mandrill::API.new
      message = {  
       # :merge_vars => mandrill_mergevars_array,
       # :merge => true,
       :subject=> "Game On: #{event_name}",  
       :from_name=> "GameStarter <noreply@eventstarter.co>",  
       :text=>"Your gamestarter event #{event_name} is on.  Please, plan on attending, since you are 'in'.",  
       :to=> mandrill_to_array,  
       :html=>"<html><h2>Your GameStarter event #{event_name} is on!</h2><p>Please, plan on attending, since you are 'in'.</p></html>",  
       :from_email=>"sender@gamestarter.herokuapp.com"  
      }  
      sending = m.messages.send message  
      sending
    end

    # Sends Game On email to ONLY new recipients after minimum has been met 
    # -- but basically tell them its still cool to come b/c the max number has not been met
    def send_game_already_on(email, event_id, event_name)
      m = Mandrill::API.new
      message = {   
       :subject=> "Game On: #{event_name}",  
       :from_name=> "GameStarter <noreply@eventstarter.co>",  
       :text=>"Your GameStarter '#{event_name}' is now on. Please come out since you said your in on your RSVP.",  
       :to=> [{
          :email => "#{email}",
          :name => ""
        }],  
       :html=>"<html><h2>Your GameStarter event '#{event_name}' is now on.</h2><p>#{event_name}</p><p>The minimum number has been met for this event, but the max has not yet been met.</p></html>",  
       :from_email=>"sender@gamestarter.herokuapp.com"  
      }  
      sending = m.messages.send message  
      sending
    end

    # Sends Game off message for the following scenarios
    #
    # 1) The minimum number was not met by the deadline
    # 2) The maximum number was reached by the time this user clicked the "I'm In" button
    def send_game_rejection(email, event_id, event_name)
      m = Mandrill::API.new
      message = {   
       :subject=> "Game FULL: #{event_name}",  
       :from_name=> "GameStarter <noreply@eventstarter.co>",  
       :text=>"Your GameStarter event #{event_name} is FULL, and the maximum number of attendees has been met. We hope to catch you next time.",  
       :to=> [{
          :email => "#{email}",
          :name => ""
        }],  
       :html=>"<html><h2>Your GameStarter event #{event_name} is FULL.</h2><p>#{event_name}</p><p>The maximum number has been met for this event. Sorry, we hope to catch you next time.</p></html>",  
       :from_email=>"sender@gamestarter.herokuapp.com"  
      }  
      sending = m.messages.send message  
      sending
    end

    # This method sends the email out to the Creator to confirm the event is created and the invitees list has been sent to
    # 
    # 
    def send_event_create_confirmation(email, event_id, event_name)
      m = Mandrill::API.new
      message = {   
       :subject=> "Event Created and Sent on Gamestarter",  
       :from_name=> "GameStarter <noreply@eventstarter.co>",  
       :text=>"You created a new gamestarter event, and you send out emails to your list. Details attached: ...",  
       :to=> [{
          :email => "#{email}",
          :name => ""
        }],  
       :html=>"<html><h2>GameStarter Event Created and Sent</h2><p>Event Name: #{event_name}</p><p>See Event coming soon(put in details).</p></html>",  
       :from_email=>"sender@gamestarter.herokuapp.com"  
      }  
      sending = m.messages.send message  
      sending
    end
  end
end