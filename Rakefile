
task :compile do
	Dir.chdir 'interview_workspace'
	sh 'pub build'
	Dir.chdir '..'
	sh 'rm -r public/'
	sh 'cp -r interview_workspace/build/web public/'
end
