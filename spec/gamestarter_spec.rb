require 'rubygems'
require 'bundler/setup'
require 'rspec'
require_relative '../gamestarter'

describe GameStarter::Event do
  describe '.initialize' do
    let(:example_one) {GameStarter::Event.new(1200, 100, 'Bball', 'The Gym', 1, 10, 'Taylor', '404-555-5555', 'clay@example.com', 'alice@example.com, bill@example.com')}
    it 'creates an event object' do
      expect(example_one).to be_a(GameStarter::Event)
    end
    it 'sets parameters correctly' do
      expect(example_one.event_time).to eq(1200)
      expect(example_one.deadline).to eq(100)
      expect(example_one.event_name).to eq('Bball')
      expect(example_one.event_location).to eq('The Gym')
      expect(example_one.minimum_attendees).to eq(1)
      expect(example_one.maximum_attendees).to eq(10)
      expect(example_one.creator).to be_a(GameStarter::Creator)
      expect(example_one.creator.name).to eq('Taylor')
      expect(example_one.creator.phone).to eq('404-555-5555')
      expect(example_one.creator.email).to eq('clay@example.com')
      expect(example_one.invitees).to eq(['alice@example.com', 'bill@example.com'])
      expect(example_one.attendees).to eq([])
    end
  end
end

describe GameStarter::Creator do
  describe '.initialize' do
    let(:example_two) {GameStarter::Creator.new('Randy Randerson', '555-555-5555', 'randy@randy.com')}
    it 'creates a creator object' do
      expect(example_two).to be_a(GameStarter::Creator)
    end
    it 'sets parameters correctly' do
      expect(example_two.name).to eq('Randy Randerson')
      expect(example_two.phone).to eq('555-555-5555')
      expect(example_two.email).to eq('randy@randy.com')
    end
  end
end

describe GameStarter::Attendee do
  describe '.initialize' do
    let(:example_three) {GameStarter::Attendee.new('tester@testing.com')}
    it 'creates an attendee object' do
      expect(example_three).to be_a(GameStarter::Attendee)
    end
    it 'sets paramters correctly' do
      expect(example_three.email).to eq('tester@testing.com')
      expect(example_three.attending).to be_false
    end
  end
end