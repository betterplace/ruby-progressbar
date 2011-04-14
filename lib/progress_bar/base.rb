module ProgressBar
  class Base
    include ProgressBar::OptionsParser
    include ProgressBar::LengthCalculator
    include ProgressBar::Formatter

    DEFAULT_OUTPUT_STREAM     = STDERR
    DEFAULT_FORMAT_STRING     = '%t: |%b|'

    def initialize(options = {})
      @out             = options[:output_stream]         || DEFAULT_OUTPUT_STREAM

      @length_override = ENV['RUBY_PROGRESS_BAR_LENGTH'] || options[:length]

      @format_string   = options[:format]                || DEFAULT_FORMAT_STRING

      @title           = Components::Title.new(title_options_from(options))
      @bar             = Components::Bar.new(bar_options_from(options))
      @estimated_time  = Components::EstimatedTimer.new(:beginning_position => @bar.current, :total => @bar.total)
      @elapsed_time    = Components::ElapsedTimer.new
    end

    def clear
      @out.print clear_string
    end

    def start(options = {})
      clear

      @bar.current            = options[:at] || @bar.current
      @estimated_time.current = options[:at] || @estimated_time.current

      @estimated_time.start
      @elapsed_time.start

      update
    end

    def finish
      @bar.finish
      @estimated_time.finish

      update
    end

    def finished?
      @bar.current == @bar.total
    end

    def inc
      puts "#inc is deprecated.  Please use #increment"
      increment
    end

    def increment
      @bar.increment
      @estimated_time.increment

      update
    end

    def title
      @title
    end

    def to_s(format_string = nil)
      format_string ||= @format_string

      format(format_string)
    end

    def inspect
      "#<ProgressBar:#{@bar.current}/#{@bar.total}>"
    end

    private
      attr_reader         :out

      def clear_string
        "#{" " * length}\r"
      end

      def stop_timers
        # @estimated_time.stop
        @elapsed_time.stop
      end

      def update
        stop_timers if finished?

        if length_changed?
          clear
          reset_length
        end

        @out.print self.to_s + eol
        @out.flush
      end

      def eol
        finished? ? "\n" : "\r"
      end

      # def reset
      # end

      # def halt
        # stop
      # end

      # def stop
        # update
      # end

      # def pause
        # update
      # end
  end
end
