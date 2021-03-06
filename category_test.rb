require './category'
require 'minitest/autorun'

class CategoryTest < MiniTest::Test

	def test_mismatched_item_number
		five = Category.new("{} on weekends", "What do you do on weekends?", ["dance", "swim", "play baseball", "listen to music", "study Japanese"])
		two = Category.new("{} on weekends", "What do you do on weekends?", ["dance", "study Japanese"])
		assert_raises Exception do
			Category.latex_descriptions_from_categories([five, two])
		end
	end

end

