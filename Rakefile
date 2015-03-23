
task :test do
	`ruby web_test.rb`
	`ruby category_test.rb`
end

task :generate do
	Dir.chdir 'interview_workspace'
	`compass compile`
	`python generate_pages.py`
	Dir.chdir '..'
end

task :compile => [:generate] do
	Dir.chdir 'interview_workspace'
	sh 'pub build'
	Dir.chdir '..'
end

