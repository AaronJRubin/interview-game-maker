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

	# A fragment is something like "{} on weekends", or "favorite food is {}"
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

	def self.person_set(description_sets, name_roulette)
		item_count = description_sets.first.length
		people = []
		shuffled_description_sets = description_sets.map do |description_set| description_set.shuffle end
		(0...item_count).each do |item_number|
			paragraph = ["Your name is #{name_roulette.next_name}"]
			this_persons_descriptions = shuffled_description_sets.map do |description_set| description_set[item_number] end
			paragraph.concat(this_persons_descriptions)
			people << paragraph
		end	
		return people
	end

	def self.latex_descriptions_from_categories(categories) 
		validate_category_counts(categories)
		document = PdfBuilder.new(two_columns: true)
		description_sets = categories.map do |category| category.descriptions end
		name_roulette = NameRoulette.new
		people_to_find = categories.count
		people_to_find.times do
			person_set(description_sets, name_roulette).each do |person| document.addParagraph(person) end 
		end
		document.startBold
		extra_people = []
		while extra_people.length < 5
			extra_people.concat(person_set(description_sets, name_roulette))
		end
		extra_people.take(5).each do |extra_person| document.addParagraph(extra_person) end
		document.endBold
		document.endDocument
		return document.latexDocument
	end

	def self.latex_tasks_from_categories(categories) 
		validate_category_counts(categories)
		document = PdfBuilder.new(two_columns: false)
		people_to_find = categories.count
		categories.each do |category|
			category.tasks(people_to_find).each do |task|
				paragraph = [task, category.hint]
				document.addParagraph(paragraph)
			end
		end
		all_tasks = categories.each.map do |category|
			category.tasks(people_to_find).each.map do |task|
				[task, category.hint]
			end
		end . flatten(1)
		document.startBold
		all_tasks.shuffle!
		all_tasks.take(5).each do |task| document.addParagraph(task) end
		document.endBold
		document.endDocument	
		return document.latexDocument
	end
end

class NameRoulette

	NAMES = ["Edward", "Emma", "Ellie", "Emmett", "Evan", 
					"Alex", "Alexis", "Andrew", "Amelia", "Amanda",
					"Dennis", "Denise", "Daniel", "David", "Dwight",
					"Brian", "Bob", "Betty", "Barry", "Barney",
					"Max", "Mindy", "Michelle", "Michael", "Martin",
					"Steve", "Joe", "Stephanie", "Sam", "Samantha",
					"Simon", "Jennifer", "Jeff", "Jake", "Elliot"]

	def initialize
		@names = NAMES.shuffle
		@current_name = -1
	end

	def next_name
		@current_name += 1
		@names[@current_name % @names.length]
	end
end
