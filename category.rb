require 'humanize'
require './pdf_builder'

=begin
Keep in mind the following equations:

items_per_category * category_count * people_to_find (instances of a particular attribute) == total_attributes

category_count * total_people == total_attributes

And therefore (by simple algebra):

items_per_category * people_to_find = total_people

Strictly speaking, for the purposes of game enjoyment,
the left hand of the equals sign only sets a LOWER BOUND on total_people,
i.e., items_per_category * people_to_find <= total_people.
This is because having a few extra people doesn't actually mess up the game,
it just makes a few lucky students have somewhat easier tasks.

Also note the following equation:

items_per_category * number_of_categories = total_tasks

If we want total_tasks to equal total_people:

items_per_category * people_to_find = items_per_category * number_of_categories

And hence:

people_to_find = number_of_categories

So:

items_per_category * number_of_categories <= total_people.

So, 1 category, with 5 items in that category, implies 5 total people and 1 person to find.
2 categories, with 5 items in each, implies 10 total people and 2 people to find.

=end

class Category

	require 'set'

	GAP = "{}"

	NAMES = ["Edward", "Emma", "Ellie", "Emmett", "Evan", 
	"Alex", "Alexis", "Andrew", "Amelia", "Amanda",
	"Dennis", "Denise", "Daniel", "David", "Dwight",
	"Brian", "Bob", "Betty", "Barry", "Barney",
	"Max", "Mindy", "Michelle", "Michael", "Martin",
	"Steve", "Joe", "Stephanie", "Sam", "Samantha",
	"Simon", "Jennifer", "Jeff", "Jake", "Elliot"]
	
	# A fragment is something like "{{}} on weekends", or "favorite food is {{}}"
	def initialize(fragment, question, items, possessive = false)
		if fragment.end_with?('.')
			fragment.chop!
		end
		@fragment = fragment
		@question = question
		@items = items
		@possessive = possessive
	end

	def to_map
		{fragment: @fragment, question: @question, items: @items, possessive: @possessive}
	end

	def generate_fragment(item)
		@fragment.sub(GAP, item)
	end

	def generate_task(item, people_to_find)
		"#{people_to_find.humanize.capitalize} people#{@possessive ? "'s" : ""} #{generate_fragment(item)}. Find those people."
	end

	def generate_description(item)
		"#{@possessive ? "Your" : "You"} #{generate_fragment(item)}."
	end

	def tasks(people_to_find)
		@items.map do |item| generate_task(item, people_to_find) end
	end

	def descriptions
		@items.map do |item| generate_description(item) end
	end

	def hint
		"Hint: Ask, \`\`#{@question}\""
	end

	def item_count
		@items.count
	end

	def self.validate_category_counts(categories)
		if Set.new(categories.map do |category| category.item_count end).count != 1
			raise Exception.new("Every category must have the same amount of items!")
		end
	end

	def self.latex_descriptions_from_categories(categories, people_to_find = 5)
		validate_category_counts(categories)
		item_count = categories.first.item_count
		document = PdfBuilder.new(two_columns: true)
		shuffled_names = NAMES.shuffle
		name_index = 0
		descriptions = categories.map do |category| category.descriptions end
		people_to_find.times do
			descriptions.each do |description|
				description.shuffle!
			end
			(0...item_count).each do |item_number|
				paragraph = []
				paragraph << "Your name is #{shuffled_names[name_index]}."
				name_index = (name_index + 1) % shuffled_names.count
				descriptions.each do |description|
					paragraph << description[item_number]
				end
				document.addParagraph(paragraph)
			end
		end
		extra_count = 0
		document.startBold
		# We need to refactor this, it's not DRY at all
		while extra_count < 5 do
			descriptions.each do |description|
				description.shuffle!
			end
			(0...item_count).each do |item_number|
				paragraph = []
				paragraph << "Your name is #{shuffled_names[name_index]}."
				name_index = (name_index + 1) % shuffled_names.count
				descriptions.each do |description|
					paragraph << description[item_number]
				end
				document.addParagraph(paragraph)
				extra_count += 1
				if extra_count > 5
					break
				end
			end
		end
		document.endBold
		document.endDocument
		return document.latexDocument
	end

	def self.latex_tasks_from_categories(categories, people_to_find = 5)
		validate_category_counts(categories)
		document = PdfBuilder.new(two_columns: false)
		categories.each do |category|
			category.tasks(people_to_find).each do |task|
				paragraph = []
				paragraph << task
				paragraph << category.hint
				document.addParagraph(paragraph)
			end
		end
		all_tasks = categories.each.map do |category|
			category.tasks(people_to_find).each.map do |task|
				[task, category.hint]
			end
		end . flatten(1)
		all_tasks.shuffle!
		extra_task = 0
		document.startBold
		while extra_task < 5
			document.addParagraph(all_tasks[extra_task % all_tasks.count])
			extra_task += 1
		end
		document.endBold
		document.endDocument
		return document.latexDocument
	end
end
