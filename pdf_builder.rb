class PdfBuilder
	
	require 'base64'
	require 'rake'

	#LINES_PER_PAGE = 48

	def initialize(two_columns: false)
		@document = "\\documentclass[12pt, letterpaper]{minimal}\n"
		@document << "\\usepackage{geometry}"
		@document << "\\geometry{margin=0.25in}"
		@document << "\\setlength{\\parindent}{0pt}\n"
		if two_columns
			@document << "\\twocolumn\n"
		end
		@document << "\\widowpenalties 1 10000\n"
		@document << "\\raggedbottom\n"
		@document << "\\begin{document}\n"
		#@remaining_lines = LINES_PER_PAGE
	end

	def addParagraph(lines)
		#if (lines.count > @remaining_lines)
		#	@document << "\\pagebreak\n"
			#@remaining_lines = LINES_PER_PAGE
		#end
		#@remaining_lines -= lines.count + 1 # for blank line after paragraph
		lines.each do |line|
			@document << line + "\\\\"
		end
		@document << "\n\n"
		return
	end

	def startBold
		@document << "{\\bfseries "
		return
	end

	def endBold
		@document << "}\n"
		return
	end

	def endDocument
		@document << "\\end{document}"
		return
	end

	def latexDocument
		@document.dup
	end

	def self.writePDF(document, filename)
		file = File.new(filename.pathmap("%X.tex"), "w")
		file.write(document)
		file.close
		`pdflatex #{file.path}`
		`rm #{file.path}`
	end

	def self.base64PDF(document)
		file = Tempfile.new("")
		file.write(document)
		file.close
		`pdflatex #{file.path}`
		pdf_file = file.path.pathmap("%n.pdf")
		pdf_file_64 = Base64.encode64(IO.binread(pdf_file))
		`rm #{file.path.pathmap("%n.*")}`
		return pdf_file_64
	end
							
end
