require 'sinatra'
require 'json'
require 'rake'
require 'base64'
require './category'

get '/' do
	#weekends = Category.new("{{}} on weekends", "What do you do on weekends?", ["dance", "swim", "play baseball", "listen to music", "study Japanese"])
	#weekends.tasks.first
end

post '/' do
	content_type :json
	categories_json = params["categories"]
	categories = categories_json.map do |category_json|
		Category.new(category_json["fragment"], category_json["question"], category_json["items"], category_json["possessive"])
	end
	people_to_find = params["people_to_find"].to_i
	description_latex = Category.descriptions_from_categories(categories, people_to_find)
	tasks_latex = Category.tasks_from_categories(categories, people_to_find)
	description_file = Tempfile.new('descriptions')
	description_file.write(description_latex)
	description_file.close()
	tasks_file = Tempfile.new('tasks')
	tasks_file.write(tasks_latex)
	tasks_file.close()
	`pdflatex "#{description_file.path}"`
	`pdflatex "#{tasks_file.path}"`
	description_pdf = description_file.path.pathmap("%n.pdf")
	tasks_pdf = tasks_file.path.pathmap("%n.pdf")
	description_64 = Base64.encode64(IO.binread(description_pdf))
	tasks_64 = Base64.encode64(IO.binread(tasks_pdf))
	`rm #{description_pdf.pathmap("%n.*")}`
	`rm #{tasks_pdf.pathmap("%n.*")}`
	{"descriptions" => description_64, "tasks" => tasks_64}.to_json
end
