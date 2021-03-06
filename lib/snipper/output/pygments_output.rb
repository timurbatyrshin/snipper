class Snipper
  class Output
    class Pygments_Output
      def initialize(snippet)
        @snippet = snippet
      end

      def self.list_langs
        Pygments.lexers.map{|l| l[1][:aliases]}.flatten.sort
      end

      def save
        theme = Config[:theme] || "default"

        raise "Please set the :public_target_dir setting" unless Config[:public_target_dir]

        path = @snippet.snippet_html_path

        FileUtils.mkdir_p(path)

        File.open(File.join(path, "index.html"), "w") do |html|
          html.puts "<head>"
          html.puts "<link rel='stylesheet' type='text/css' href='../css/#{theme}.css' media='all' />"
          html.puts "<style type='text/css'>"
          html.puts ".highlighttable { background-color: #253B76; width: 100%;}"
          html.puts ".content { width: 100%;}"
          html.puts ".linenos { text-align: right; color: white; width: 30px; }"

          if Config[:dark_theme]
            html.puts ".highlight { background-color: #0C1000 }"
          else
            html.puts ".highlight { background-color: white }"
          end

          html.puts "</style>"
          html.puts "</head>"
          html.puts "<body>"

          html.puts "<table class='content'>"
          html.puts "<tr><td>"

          @snippet.each_file do |file, text, headers|
            File.open(File.join(path, "#{File.basename(file)}.raw"), "w") do |f|
              f.puts text
            end

            syntax = headers["lang"]

            unless syntax
              lexer = Pygments::Lexer.find_by_extname(File.extname(file))

              if lexer
                syntax = lexer.name
              else
                syntax = Config[:default_syntax] || "ruby"
              end
            end

            raise "Unknown syntax #{syntax}" unless self.class.list_langs.include?(syntax)


            html.puts "<H2>%s</H2>" % [ headers["description"] ] if headers["description"]
            html.puts Pygments.highlight(text, :lexer => syntax, :options => {:linenos => "table", :style => theme})
            html.puts "syntax: %s download: <a href='%s.raw'>raw</a>" % [ syntax, File.basename(file) ]
            html.puts "<br /><br />"
          end

          html.puts "</td></tr>"
          html.puts "<tr align='right'><td><a href='%s'>Snipper</a></td></tr>" % [ "http://github.com/ripienaar/snipper" ]
          html.puts "</table>"
          html.puts "</body>"
        end
      end
    end
  end
end
