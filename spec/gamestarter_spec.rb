require 'rubygems'
require 'bundler/setup'
require 'rspec'
require_relative '../gamestarter'

describe GameStarter::Event do
  describe '.initialize' do
    it 'creates an event object' do
      example_one = GameStarter::Event.new(1200, 100, event_name, event_location, minimum_attendees, maximum_attendees, creator_name, phone, email, invitees)
      expect (example_one).to be_a(GameStarter::Event)
    end
  end
end