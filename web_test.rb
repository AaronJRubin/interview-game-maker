require 'minitest/autorun'
require 'rack/test'

require './web.rb'

class WebTest < MiniTest::Unit::TestCase

	include Rack::Test::Methods

	def app
		App.new
	end

	def test_get
		get '/'
		assert last_response.ok?
	end

	def test_post
		weekends = Category.new("{} on weekends", "What do you do on weekends?", ["dance", "swim", "play baseball", "listen to music", "study Japanese"])
		foods = Category.new("favorite food is {}", "What is your favorite food?", ["pizza", "sushi", "ramen", "karaage", "ice cream"])
		post '/', {categories: [weekends.to_map, foods.to_map]}.to_json
		assert last_response.ok?
		assert last_response.body.include?("descriptions")
		assert last_response.body.include?("tasks")
	end

end
