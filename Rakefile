
task :test do
	`ruby web_test.rb`
	`ruby category_test.rb`
end

task :compile do
	Dir.chdir 'interview_workspace'
	sh 'pub build'
	Dir.chdir '..'
end

