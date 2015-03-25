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
		description_latex = Category.latex_descriptions_from_categories(categories) 
		tasks_latex = Category.latex_tasks_from_categories(categories)
		description_64 = PdfBuilder.base64PDF(description_latex)
		tasks_64 = PdfBuilder.base64PDF(tasks_latex)
		{"descriptions" => description_64, "tasks" => tasks_64}.to_json
	end

end
