require 'sinatra'
require 'json'
require 'rake'
require 'base64'
require './category'
require './pdf_builder'

use Rack::Deflater 

class App < Sinatra::Application

	set :public_folder, 'interview_workspace/build/web'

	get '/' do
		redirect '/make-game.html'
	end

	post '/' do
		data = JSON.parse request.body.read
		categories_json = data["categories"]
		categories = categories_json.map do |category_json|
			Category.new(category_json["fragment"], category_json["question"], category_json["items"], category_json["possessive"])
		end
		if Category.validate_category_counts(categories)
			description_latex = Category.latex_descriptions_from_categories(categories) 
			tasks_latex = Category.latex_tasks_from_categories(categories)
			description_64 = PdfBuilder.base64PDF(description_latex)
			tasks_64 = PdfBuilder.base64PDF(tasks_latex)
			{"descriptions" => description_64, "tasks" => tasks_64}.to_json
		else
			"You sent categories with a nonmatching number of items. Please send again, making sure that each category has the same number of items"
		end
	end

end
