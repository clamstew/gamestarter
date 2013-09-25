require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'thin'
require 'unirest'
require 'json'
require 'mandrill'

require_relative 'lib/event'



get '/' do

  # 'hello world'
  erb :index
end

# # get '/event' do
# #   example_event = GameStarter::Event.new(time, deadline, event_name, event_location, attendees, minimum, maximum, creator_name, phone, email)
# #   example_event.inspect
# end

# New event form
get '/new_event' do
  erb :add_event_form
end

# Route for event creators to add an event
post '/add_event' do 
  
  @event_name = params[:event_name]
  # form in /new_event posts to here for processing
  @creator_name = params[:creator_name]
  @creator_email = params[:creator_email]
  @creator_phone = params[:creator_phone]
  @event_time = params[:event_time]
  @event_location = params[:event_location]
  @invitees = params[:invitees]
  @minimum_attendees = params[:minimum_attendees]
  @maximum_attendees = params[:maximum_attendees]
  @deadline = params[:deadline]

  # create an event in firebase database
  new_event = GameStarter::Event.new(@event_time, @deadline, @event_name, @event_location, @minimum_attendees, @maximum_attendees, @creator_name, @creator_phone, @creator_email, @invitees) 
  result = new_event.add_to_firebase

  @event_id = result.raw_body[9..-3]  

  # Send an email to invitees
  email = GameStarter::MandrillEmail.new()
  email.send_are_you_in(new_event.invitees, @event_id.to_s)

  # Send email to event creator
  email2 = GameStarter::MandrillEmail.new()
  email2.send_event_create_confirmation(@creator_email, @event_id.to_s, @event_name)

  erb :form_result
end

# Invitees are sent this route in an email when the creator specifies them
get '/reply/:event_id/:invitee_email' do
  @event_id = params[:event_id]
  @invitee_email = params[:invitee_email]
  attendee = GameStarter::Attendee.new(params[:invitee_email])
  @result = attendee.get_event_from_firebase(params[:event_id]) # Test this with a mock object
  # @result = JSON.load(@result)
  # @code = result.code
  erb :reply 
end

# Route for when attendees click "I'm In"
post '/im_in' do

  @event_id = params[:event_id]
  @attendee_email = params[:invitee_email]
  @attendees = Unirest::get("https://gamestarter.firebaseio.com/events/#{@event_id}/attendees/.json",
  { "Accept" => "application/json" })

  # Get the minimum number of attendees for this event
  @minimum_attendees = Unirest::get("https://gamestarter.firebaseio.com/events/#{@event_id}/minimum/.json",
  { "Accept" => "application/json" })
  @minimum_attendees = @minimum_attendees.body
  @minimum_attendees = @minimum_attendees.gsub(/[^0-9]/,'')
  @minimum_attendees = @minimum_attendees.to_i

  # Get the maximum number of attendees for this event
  @maximum_attendees = Unirest::get("https://gamestarter.firebaseio.com/events/#{@event_id}/maximum/.json",
  { "Accept" => "application/json" })
  @maximum_attendees = @maximum_attendees.body
  @maximum_attendees = @maximum_attendees.gsub(/[^0-9]/,'')
  @maximum_attendees = @maximum_attendees.to_i

  # Get the maximum number of attendees for this event
  @event_name = Unirest::get("https://gamestarter.firebaseio.com/events/#{@event_id}/event_name/.json",
  { "Accept" => "application/json" })
  @event_name = @event_name.body

  # if attendees in this firebase event is empty
  if @attendees.raw_body == "null"
    array = {}
    @attendees_body = @attendees.body
    @attendees_body = array
    new_attendees_array = @attendees_body[:email1] = @attendee_email
    response = Unirest::post("https://gamestarter.firebaseio.com/events/#{@event_id}/attendees/.json",
    { "Accept" => "application/json" }, new_attendees_array.to_json)
    @counter_of_attendees = 1

  # if attendees in this firebase event has 1 or more emails in it
  elsif @attendees.raw_body != "null"
      @attendees_id = @attendees.body
      
      # if attendees in this firebase event has ONLY 1 email in it
      # it will appear as a hash and need to be treated as one 
      # - and turned into an array which is what we want
      if @attendees_id.is_a? Hash
        i = 0
        @attendees_id.each do |x,y| 
          if i == 0
            @first_key = x
          end
          i += 1
        end
        @counter_of_attendees = i
        # @TODO: put a pry thing here and see what i equals

        @new_attendees_array = @attendees_id[@first_key] = @attendees_id[@first_key] + ", #{@attendee_email}" 
        @new_attendees_array = @new_attendees_array.split(',')
        @new_attendees_array.collect! do |x|
          x.strip
        end
        response = Unirest::put("https://gamestarter.firebaseio.com/events/#{@event_id}/attendees/.json",
        { "Accept" => "application/json" }, @new_attendees_array.to_json)

        # ======== IF MIN NUMBER IS 2 --- THEN EMAIL LOGIC ALSO NEEDS TO GO HERE
        #     EMAIL LOGIC
        # if @counter_of_attendees == @minimum_attendees

        #   email_game_on = GameStarter::MandrillEmail.new
        #   email_game_on.send_game_on(@new_attendees_array, @event_id, @event_name)

        # elsif @counter_of_attendees > @minimum_attendees && @counter_of_attendees <= @maximum_attendees

        #   email_game_on = GameStarter::MandrillEmail.new
        #   email_game_on.send_game_already_on(@attendee_email, @event_id, @event_name)
        
        # else @counter_of_attendees > @maximum_attendees
        #   email_game_full = GameStarter::MandrillEmail.new
        #   email_game_full.send_game_rejection(@attendee_email, @event_id, @event_name)

        # end

      # if attendees in this firebase event has GREATER THAN 1 email in it  
      # it will appear as an array and you can do array pushes on it
      elsif @attendees_id.is_a? Array
        @new_attendees_array = @attendees_id << @attendee_email
        @counter_of_attendees = @new_attendees_array.count
        response = Unirest::put("https://gamestarter.firebaseio.com/events/#{@event_id}/attendees/.json",
        { "Accept" => "application/json" }, @new_attendees_array.to_json)

        if @counter_of_attendees == @minimum_attendees
          # send email to all attendees 
          # Send an email
          # email_game_on = GameStarter::Email.new
          # email_game_on.send_game_on(@new_attendees_array, @event_id)
          email_game_on = GameStarter::MandrillEmail.new
          email_game_on.send_game_on(@new_attendees_array, @event_id, @event_name)

        elsif @counter_of_attendees > @minimum_attendees && @counter_of_attendees <= @maximum_attendees

          email_game_on = GameStarter::MandrillEmail.new
          email_game_on.send_game_already_on(@attendee_email, @event_id, @event_name)
        
        else @counter_of_attendees > @maximum_attendees
          email_game_full = GameStarter::MandrillEmail.new
          email_game_full.send_game_rejection(@attendee_email, @event_id, @event_name)

        end
      end
  end
  erb :attend_confirmation
end