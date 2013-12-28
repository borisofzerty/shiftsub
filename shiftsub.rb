require 'optparse'

class Shifter
  attr_accessor :in_p, :out_p, :time_f
  # regexp for valid sub-timing line $1 => 1st time, $2 => 2nd time
  GL_RE = /(\d\d:\d\d:\d\d,\d{3}) --> (\d\d:\d\d:\d\d,\d{3})/

  # TODO line_regexp - transofrm in commented regexp
  # $1 hours 1st time, $2 min 1st time,...
  # $5 .. $8 2nd time values
  #              $1     $2     $3     $4          $5     $6     $7     $8
  FULL_RE = /\A(\d\d):(\d\d):(\d\d),(\d{3}) --> (\d\d):(\d\d):(\d\d),(\d{3})/

  # will parse options, and fill @time_f, @f_in and @f_out variables
  # will print error message if wrong parameters are given
  def initialize(shift_time, in_p = nil, out_p = nil)
    # TODO check args
    @in_p, @out_p, @shift_time = in_p, out_p, shift_time
  end

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

  def convert
    openfiles
    @f_in.each_line do |line|
      if line =~ FULL_RE
        #TODO use array to avoid writing same code 2 times
        t1 = Time::mktime(0, 1, 1, $1.to_i, $2.to_i, $3.to_i, $4.to_i * 1000)
        t1 += @shift_time
        t1 = t1.strftime("%H:%M:%S,%L")

        t2 = Time::mktime(0, 1, 1, $5.to_i, $6.to_i, $7.to_i, $8.to_i * 1000)
        t2 += @shift_time
        t2 = t2.strftime("%H:%M:%S,%L")
        puts t1 + " --> " + t2
      else
        @f_out.write(line)
      end
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
time_f *= -1 if sign =~ /-/

s = Shifter::new(time_f,ARGV[1],ARGV[2])
s.convert
