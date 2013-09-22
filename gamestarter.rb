require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'thin'
require 'unirest'
require 'json'

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

  # Send an email
  email = GameStarter::Email.new
  email.send(new_event.invitees, @event_id.to_s)

  erb :form_result
end

# Invitees are sent this route in an email when the creator specifies them
get '/reply/:event_id/:invitee_email' do
  @event_id = params[:event_id]
  @invitee_email = params[:invitee_email]
  attendee = GameStarter::Attendee.new(params[:invitee_email])
  @result = attendee.get_event_from_firebase(params[:event_id])
  # @result = JSON.load(@result)
  # @code = result.code
  erb :reply 
end

# Route for when attendees click "I'm In"
post '/im_in' do
  # def json_to_sym_hash(json)
  #   json.gsub!('\'', '"')
  #   parsed = JSON.parse(json)
  #   symbolize_keys(parsed)
  # end

  # def symbolize_keys(hash)
  #   hash.inject({}){|new_hash, key_value|
  #     key, value = key_value
  #     value = symbolize_keys(value) if value.is_a?(Hash)
  #     new_hash[key.to_sym] = value
  #     new_hash
  #   }
  # end


  @event_id = params[:event_id]
  @attendee_email = params[:invitee_email]
  @attendees = Unirest::get("https://gamestarter.firebaseio.com/events/#{@event_id}/attendees/.json",
  { "Accept" => "application/json" })
  @minimum_attendees = Unirest::get("https://gamestarter.firebaseio.com/events/#{@event_id}/minimum/.json",
  { "Accept" => "application/json" })
  @minimum_attendees = @minimum_attendees.body
  @minimum_attendees = @minimum_attendees.gsub(/[^0-9]/,'')
  @minimum_attendees = @minimum_attendees.to_i
  if @attendees.raw_body == "null"
    array = {}
    @attendees_body = @attendees.body
    @attendees_body = array
    # @attendees_body = array << @attendee_email
      new_attendees_array = @attendees_body[:email1] = @attendee_email
    ### @attendees_json = @attendees.body.to_a << 
    # @attendees_json = @attendees_body.to_json
    response = Unirest::post("https://gamestarter.firebaseio.com/events/#{@event_id}/attendees/.json",
    { "Accept" => "application/json" }, new_attendees_array.to_json)
  elsif @attendees.raw_body != "null"
    # @attendees_id = @attendees.body[0] # 2..21
      @attendees_id = @attendees.body
      
      if @attendees_id.is_a? Hash
        i = 0
        @attendees_id.each do |x,y| 
          if i = 0
            @first_key = x
          end
          i += 1
        end
        @counter_of_attendees = i



        @new_attendees_array = @attendees_id[@first_key] = @attendees_id[@first_key] + ", #{@attendee_email}" 
        @new_attendees_array = @new_attendees_array.split(',')
        @new_attendees_array.collect! do |x|
          x.strip
        end
        response = Unirest::put("https://gamestarter.firebaseio.com/events/#{@event_id}/attendees/.json",
        { "Accept" => "application/json" }, @new_attendees_array.to_json)

        # if @counter_of_attendees >= @maximum_attendees
          # send email to all attendees 
          # email = GameStarter::Email.new
          # email.send_game_on(@new_attendees_array, @event_id)
        # end

      elsif @attendees_id.is_a? Array
        # @new_attendees_array = 'this came back as an array'
        @new_attendees_array = @attendees_id << @attendee_email
        @counter_of_attendees = @new_attendees_array.count
        response = Unirest::put("https://gamestarter.firebaseio.com/events/#{@event_id}/attendees/.json",
        { "Accept" => "application/json" }, @new_attendees_array.to_json)

        if @counter_of_attendees >= @minimum_attendees
          # send email to all attendees 
          # Send an email
          email_game_on = GameStarter::Email.new
          email_game_on.send_game_on(@new_attendees_array, @event_id)
        end
      end
  end
  # @awesome = @response.body
  # @response = JSON.load(@awesome)
  # if @response['attendees'] == "null"
  #   @response['attendees'] = []
  #   @response['attendees'] << "#{@attendee_email}"
  #   @response_json = response.to_json
  #   @response = Unirest::post("https://gamestarter.firebaseio.com/events/#{@event_id}.json", { "Accept" => "application/json" }, @response_json)
  # end

  
  # @attendees_count = @attendees.count
  erb :attend_confirmation

end