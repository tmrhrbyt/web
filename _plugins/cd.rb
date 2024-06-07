# Made by me :)
# Feel free to use if you give credit

require "base64"

module Jekyll
  module Tags
    class CDTag < Liquid::Block

      def initialize(tag_name, markup, tokens)
        super
        arr = markup.split("s:")
        if arr[1] != nil
          @scale = arr[1].to_i
        else
          @scale = 60
        end
        @caption = arr[0].strip
      end

      def render(context)
        site = context.registers[:site]

        converter = site.find_converter_instance(::Jekyll::Converters::Markdown)
        caption = converter.convert(@caption).gsub(/<\/?p[^>]*>/, '').chomp

        code = super(context)

        latex = <<EOF
\\documentclass[tikz]{standalone}
\\usepackage{tikz-cd}
\\usepackage{amssymb}
\\usepackage{amsmath}
\\begin{document}
\\begin{tikzcd}#{code}\\end{tikzcd}
\\end{document}
EOF

        Dir.mktmpdir do |dir|
          File.write("#{dir}/cd.tex", latex)
          raise "pdflatex" unless system("pdflatex -output-directory #{dir} #{dir}/cd.tex")
          raise "inkscape" unless system("inkscape -l --export-filename=#{dir}/cd.svg #{dir}/cd.pdf")
          raise "scour" unless system("scour -i #{dir}/cd.svg -o #{dir}/optimized_cd.svg --enable-viewboxing --enable-id-stripping --enable-comment-stripping --shorten-ids --indent=none")
          svg = File.read("#{dir}/optimized_cd.svg")
          return <<EOF
<figure class="cdfig">
  <img class="cd" style="width: #{@scale}%;" src="data:image/svg+xml;base64,#{Base64.encode64(svg)}" alt="A commutative diagram"/>
  <figcaption>#{@caption}</figcaption>
</figure>
EOF
        end

        "<details><summary>#{caption}</summary>#{body}</details>"
      end

    end
  end
end

Liquid::Template.register_tag('cd', Jekyll::Tags::CDTag)
