require 'optparse'

def parse
  options = {}

  opt_parser = OptionParser.new do |opt|
    opt.banner = "Usage: #{$0} ADD|SUB [-t TIME]"

    opt.on("-t","--time TIME","time to add/substract from subtitles") do |time|
      # TODO: check if time is valid
      options[:time] = (time.to_f * 1000).to_i
    end

    opt.on("-h","--help","help") do
      puts opt_parser
    end
  end

  opt_parser.parse!

  unless ARGV[0].is_a?(String)
    puts opt_parser
    exit 1
  end

  case ARGV[0]
  when /ADD/
    options[:time] *= 1
  when /SUB/
    options[:time] *= -1
  else
    puts opt_parser
    exit 1
  end

  return options
end

# convert millisecond in string
# ms: (Fixnum)
# RETURN: (String) in format hh:mm:ss,mmmm
def ms_to_st(ms)
  milli = ms % 1000
  ms -= milli
  ms /= 1000

  sec = ms % 60
  ms /= 60

  min = ms % 60
  ms /= 60

  hours = ms

  return sprintf("%02d:%02d:%02d,%03d", hours, min, sec, milli)

end

# convert string in milliseconds
# st: (String) in format hh:mm:ss,mmmm
# RETURN: (Fixnum) amount of milisecond
def st_to_ms(st)
  hmsm_re = /(\d\d):(\d\d):(\d\d),(\d{3})/
  st.match(hmsm_re)
  return ($1.to_i * 3600 + $2.to_i * 60 + $3.to_i) * 1000 + $4.to_i
end

# add or substract time from a string
# original: (String) time in the format hh:mm:ss,mmm
# delay: (Fixnum) time to add in milliseconds
# RETURN: (String) updated time string
def change_time(original, delay)
  original = st_to_ms(original)
  return ms_to_st(original + delay)
end

options = parse

# TODO: multiline match
# TODO: put this into a function
gl_re = /(\d\d:\d\d:\d\d,\d{3}) --> (\d\d:\d\d:\d\d,\d{3})/
$stdin.each_line do |line|
  if line =~ gl_re
    ut_1 = (st_to_ms($1) + options[:time])
    ut_2 = (st_to_ms($2) + options[:time])
    puts ms_to_st(ut_1) + " --> " + ms_to_st(ut_2)
  else
    puts line
  end
end
