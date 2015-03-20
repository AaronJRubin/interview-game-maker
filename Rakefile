
task :compile do
	Dir.chdir 'interview_workspace'
	sh 'pub build'
	Dir.chdir '..'
	sh 'rm -r public/'
	sh 'cp -r interview_workspace/build/web public/'
end

task :copy_css do
	sh 'cp interview_workspace/web/main.css public/main.css'
end
