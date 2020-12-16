module Jekyll
    class UpcaseConverter < Converter
      safe true
      priority :low

      def matches(ext)
        ext =~ /^\.md$/i
      end
  
      def output_ext(ext)
        ".json"
      end
  
      def convert(content)
        content.upcase
      end
    end
  end