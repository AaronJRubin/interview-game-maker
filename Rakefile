
task :test do
	tests = FileList.new("*_test.rb")
	tests.each do |test| sh "bundle exec ruby #{test}" end	
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

