zrequire 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'

get '/' do

  # 'hello world'
  erb :index
end

get '/event' do
  example_event = new GameStarter::Event.new(time, deadline, event_name, location, attendees, minimum, maximum, creator_name, phone, email)
  example_event.inspect
end

get '/new_event' do
  erb :add_event_form
end

post '/add_event' do
  @event_name = params[:event_name]
  # form in /new_event posts to here for processing
  "event sent. .. redirect to home #{@event_name}"
  @creator_name = params[:creator_name]
  @creator_email = params[:creator_email]
  @event_time = params[:event_time]
  @location = params[:location]
  @attendees = params[:attendees]
  @minimum_attendees = params[:minimum_attendees]
  @maximum_attendees = params[:maximum_attendees]
  @deadline = params[:deadline]
end