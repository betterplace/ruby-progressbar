class ProgressBar
  module Components
    class Bar
      include Progressable
      include Term::ANSIColor

      DEFAULT_PROGRESS_MARK = '='

      attr_accessor :progress_mark
      attr_accessor :length

      def initialize(options = {})
        super

        self.progress_mark   = options[:progress_mark] || DEFAULT_PROGRESS_MARK
      end

      def to_s(options = {:format => :standard})
        completed_string = send(:"#{options[:format]}_complete_string")
        ' ' * [ uncolor(completed_string).size - length, 0 ].max + completed_string
      end

      def integrated_percentage_complete_string
        return standard_complete_string if completed_length < 5

        " #{percentage_completed} ".to_s.center(completed_length, progress_mark)
      end

      #def standard_complete_string
      #  progress_mark * completed_length
      #end

      def background_colored_complete_string
        gradient = Attribute['#f00'].gradient_to(
          Attribute['#ff0'], :steps => [ length / 2, 2 ].max)
        gradient += gradient.last.gradient_to(Attribute['#0f0'], :steps => [ length / 2 + 1, 2 ].max)
        ([ progress_mark ] * completed_length).zip(gradient).map do |char, gc|
          on_color(gc, char)
        end * ''
      end

      alias standard_complete_string background_colored_complete_string

      def empty_string
        ' ' * [ length - completed_length, 0 ].max
      end

    private
      def completed_length
        [ length * percentage_completed / 100, 0 ].max
      end
    end
  end
end
