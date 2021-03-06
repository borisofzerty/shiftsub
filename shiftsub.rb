require 'optparse'

class Shifter
  attr_accessor :in_p, :out_p, :time_f

  #              $1     $2     $3     $4          $5     $6     $7     $8
  FULL_RE = /\A(\d\d):(\d\d):(\d\d),(\d{3}) --> (\d\d):(\d\d):(\d\d),(\d{3})/

  # parse options, and fill @time_f, @in_p and @out_p variables
  # print error message if wrong parameters are given
  def initialize(shift_time, in_p = nil, out_p = nil)
    # TODO check args
    @in_p, @out_p, @shift_time = in_p, out_p, shift_time
  end

  # read @f_in, move subtitles by @shift_time and write new file to @f_out
  def convert
    openfiles
    @f_in.each_line do |line|
      if line =~ FULL_RE
        t = []
        t[0] = Time::mktime(0, 1, 1, $1.to_i, $2.to_i, $3.to_i, $4.to_i * 1000)
        t[1] = Time::mktime(0, 1, 1, $5.to_i, $6.to_i, $7.to_i, $8.to_i * 1000)
        t.map! do |time|
          time += @shift_time
          time = time.strftime("%H:%M:%S,%L")
        end
        @f_out.puts "#{t[0]} --> #{t[1]}"
      else
        @f_out.write(line)
      end
    end
    @f_out.close
    @f_in.close
  end

  private

  # assign File to  @f_in and @f_out, using stdin and stdout as default
  def openfiles
    if @in_p
      @f_in = File::open(@in_p, "r")
      if @out_p
        @f_out = File::open(@out_p, "w")
      else
        @f_out = $stdout
      end
    else
      @f_in  = $stdin
      @f_out = $stdout
    end
  end
end

# is first arg is "+" or "-" just remove it and remember the sign
if ARGV[0] =~ /\A([+-])\z/
  sign = $1
  ARGV.shift
end

unless ARGV[0] =~ /\A([+-]?[0-9.]+)(ms?|s?)\z/
  $stderr.puts "wrong argument"
  exit 1
end
time_f = $1.to_f
time_f /= 1000 unless $2[0] == "s"
time_f *= -1 if sign == "-"

s = Shifter::new(time_f,ARGV[1],ARGV[2])
s.convert
