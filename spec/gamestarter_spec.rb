require 'rubygems'
require 'bundler/setup'
require 'rspec'
require_relative '../gamestarter'

describe GameStarter::Event do
  describe '.initialize' do
    it 'has a creator' do