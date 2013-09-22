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
  @attendee_email = params[:invitee_email]
  @event_id = params[:event_id]
  erb :attend_confirmation  
end