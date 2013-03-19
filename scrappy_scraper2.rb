require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'dm-core'
require 'dm-sqlite-adapter'
require 'dm-timestamps'
require 'dm-migrations'
require 'pony'

# Setup the datamapper db access and create our one and only model.
relative_path = File.expand_path(File.dirname(__FILE__))
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite://#{relative_path}/previous_results.sqlite")

class Scrape
	include DataMapper::Resource

	property :id, Serial
	property :block, Text
	property :created_at, DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!

def notify(thing)
	puts "Notifying thing"
	Pony.mail(:to => ["andrew.kreps@gmail.com", "bishop.j138@gmail.com"],
			:from => "somewhere@sometime.com",
			:subject => "Keyness++",
			:body => "New xbox 360 code found.\n#{thing}")
end

# Grab the HTML using Mechanize and parse the HTML with Nokogiri.
agent = Mechanize.new
page = agent.get('http://orcz.com/Borderlands_2:_Golden_Key')
noko = Nokogiri.HTML(page.body)

thing = []
headers = []
# Here we find the table with the results class and iterate through the links.
noko.css('table.wikitable th').each do |header|
	headers.push header.children.to_s.strip

	#unless scrape	# If we find the link in our database, we've already notified.
	#	Scrape.create(:block => link.to_s)			# If not, add it to the db
	#end
end

noko.css('table.wikitable td').each_with_index do |cell, index|
	#if cell.children
	if index % 6 == 5
		xbox_code = cell.children.to_s.strip
		scrape = Scrape.first(:block => xbox_code)
		unless scrape
			Scrape.create(:block => xbox_code)
			notify (xbox_code)
		end
	end
end

#puts thing.join "\n"
#puts headers.inspect
notify(thing)
