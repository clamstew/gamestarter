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
              "content"=> "http://www.eventstarter.co/reply/#{event_id}/#{email_url_encode.strip()}"
            }
          ]
        }
        mandrill_mergevars_array.push(this_merge_vars)
      end

      m = Mandrill::API.new
      message = {  
       :merge_vars => mandrill_mergevars_array,
       :merge => true,
       :preserve_recipients=> false,
       :subject=> "New Event on EventStarter",  
       :from_name=> "EventStarter <noreply@eventstarter.co>",  
       :text=>"You have a new EventStarter event. Are you in?",  
       :to=> mandrill_to_array,  
       
       :html=>"<html><h2>Event Name: #{event_name}<p>Yes, <a href=" + '"*|REPLYURL|*"' + ">I'm in!</a></p></h2></html>",  
       :from_email=>"sender@eventstarter.co"  
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
      end

      m = Mandrill::API.new
      message = {  
       # :merge_vars => mandrill_mergevars_array,
       # :merge => true,
       :subject=> "Game On: #{event_name}",  
       :from_name=> "EventStarter <noreply@eventstarter.co>",  
       :text=>"Your EventStarter event #{event_name} is on.  Please, plan on attending, since you are 'in'.",  
       :to=> mandrill_to_array,  
       :html=>"<html><h2>Your EventStarter event #{event_name} is on!</h2><p>Please, plan on attending, since you are 'in'.</p></html>",  
       :from_email=>"sender@eventstarter.co"  
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
       :from_name=> "EventStarter <noreply@eventstarter.co>",  
       :text=>"Your EventStarter '#{event_name}' is now on. Please come out since you said your in on your RSVP.",  
       :to=> [{
          :email => "#{email}",
          :name => ""
        }],  
       :html=>"<html><h2>Your EventStarter event '#{event_name}' is now on.</h2><p>#{event_name}</p><p>The minimum number has been met for this event, but the max has not yet been met.</p></html>",  
       :from_email=>"sender@eventstarter.co"  
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
       :from_name=> "EventStarter <noreply@eventstarter.co>",  
       :text=>"Your EventStarter event #{event_name} is FULL, and the maximum number of attendees has been met. We hope to catch you next time.",  
       :to=> [{
          :email => "#{email}",
          :name => ""
        }],  
       :html=>"<html><h2>Your EventStarter event #{event_name} is FULL.</h2><p>#{event_name}</p><p>The maximum number has been met for this event. Sorry, we hope to catch you next time.</p></html>",  
       :from_email=>"sender@eventstarter.com"  
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
       :subject=> "Event Created and Sent on EventStarter",  
       :from_name=> "EventStarter <noreply@eventstarter.co>",  
       :text=>"You created a new EventStarter event, and you send out emails to your list. Details attached: ...",  
       :to=> [{
          :email => "#{email}",
          :name => ""
        }],  
       :html=>"<html><h2>EventStarter Event Created and Sent</h2><p>Event Name: #{event_name}</p><p>See Event coming soon(put in details).</p></html>",  
       :from_email=>"sender@eventstarter.com"  
      }  
      sending = m.messages.send message  
      sending
    end
  end
end
