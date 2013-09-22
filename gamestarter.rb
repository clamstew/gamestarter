require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'
# require 'pry'
# require 'pry-require_relative'
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

get '/new_event' do
  erb :add_event_form
end

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

  new_event = GameStarter::Event.new(@event_time, @deadline, @event_name, @event_location, @minimum_attendees, @maximum_attendees, @creator_name, @creator_phone, @creator_email, @invitees) 
  new_event.add_to_firebase
  email = GameStarter::Email.new
  email.send(new_event.invitees)
  erb :form_result
end

get '/reply/:event_id/:invitee_email' do
  @event_id = params[:event_id]
  @invitee_email = params[:invitee_email]
  attendee = GameStarter::Attendee.new(params[:invitee_email])
  @result = attendee.get_event_from_firebase(params[:event_id])
  # @result = JSON.load(@result)
  # @code = result.code
  erb :reply 
end

post '/im_in' do
  
end












