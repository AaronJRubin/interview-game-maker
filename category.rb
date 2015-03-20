=begin
Keep in mind the following equations:

items_per_category * category_count * people_to_find (instances of a particular attribute) == total_attributes

category_count * total_people == total_attributes

And therefore (by simple algebra):

items_per_category * people_to_find = total_people

Strictly speaking, for the purposes of game enjoyment,
the left hand of the equals sign only sets a LOWER BOUND on total_people,
i.e., items_per_count * people_to_find <= total_people.
This is because having a few extra people doesn't actually mess up the game,
it just makes a few lucky students have somewhat easier tasks.
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

	LATEX_PREAMBLE = %Q{
		\\documentclass[10pt,letterpaper]{minimal}
		\\setlength{\\parindent}{0pt}
		\\twocolumn
		\\begin{document}
	}

	# A fragment is something like "{{}} on weekends", or "favorite food is {{}}"
	def initialize(fragment, question, items, possessive = false)
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
		"#{people_to_find} people#{@possessive ? "'s" : ""} #{generate_fragment(item)}. Find those people."
	end

	def generate_description(item)
		"#{@possessive ? "Your" : "You"} #{generate_fragment(item)}"
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

	def self.descriptions_from_categories(categories, people_to_find = 5)
		validate_category_counts(categories)
		item_count = categories.first.item_count
		document = String.new(LATEX_PREAMBLE)
		shuffled_names = NAMES.shuffle
		name_index = 0
		people_on_page = 0
		people_per_page = 48 / (categories.count + 2)
		descriptions = categories.map do |category| category.descriptions end
		people_to_find.times do
			descriptions.each do |description|
				description.shuffle!
			end
			(0...item_count).each do |item_number|
				document << "Your name is #{shuffled_names[name_index]}\\\\"
				name_index = (name_index + 1) % shuffled_names.count
				descriptions.each do |description|
					document << description[item_number] + '\\\\'
				end
				document << "\n\n"
				people_on_page += 1
				if people_on_page >= people_per_page
					document << "\\pagebreak\n"
					people_on_page = 0
				end
			end
		end
		document << "\\end{document}"
		return document
	end

	def self.tasks_from_categories(categories, people_to_find = 5)
		validate_category_counts(categories)
		document = %Q{
		\\documentclass[10pt,letterpaper]{minimal}
		\\setlength{\\parindent}{0pt}
		\\begin{document}
		}
		categories.each do |category|
			category.tasks(people_to_find).each do |task|
				document << task + "\\\\"
				document << category.hint + "\\\\\n\n"
			end
		end
		document << "\\end{document}"
	end
end