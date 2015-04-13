require './category.rb'
require './pdf_builder.rb'

food = Category.new("favorite food is {}", "What is your favorite food?", ["ramen", "pizza", "pasta", "omelettes", "karaage"], possessive: true)
birthplace = Category.new("were born in {}", "Where were you born", ["California", "Tokyo", "Miami", "Osaka", "New York"])
hobby = Category.new("{} on weekends", "What do you do on weekends", ["play tennis", "play soccer", "read", "swim", "practice the piano"])
dream = Category.new("want to be a {}", "What do you want to be", ["cook", "doctor", "florist", "zookeeper", "vet"])
language = Category.new("study {}", "What language do you study", ["Spanish", "French", "English", "Russian", "Arabic"])

categories = [food, birthplace, hobby, dream, language]

PdfBuilder.writePDF(Category.latex_descriptions_from_categories(categories), "sample-descriptions.pdf")
PdfBuilder.writePDF(Category.latex_tasks_from_categories(categories), "sample-tasks.pdf")

