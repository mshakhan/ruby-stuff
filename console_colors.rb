# playing with console colors

module Kernel
  CONSOLE_COLORS = {
    :none => -1,
    :bright => 1,
    :underline => 4,
    :blink => 5,
    :invert => 7,
    :black => 30,
    :red => 31,
    :green => 32,
    :yellow => 33,
    :blue => 34
  }

  alias_method :__origin_puts__, :puts
  def puts(*args)
    if args.last.is_a?(Hash) && args.last[:color]
      options = args.pop
      __origin_puts__(args.map { |arg| colorize(arg, options[:color]) })
    else
      __origin_puts__ args
    end
  end

  private
  def colorize(string, color)
    # TODO: add color mixing
    return string unless color
    "\e[#{CONSOLE_COLORS[color]}m#{string}\e[0m"
  end
end

puts 'a', 'b', 'c', :color => :red
