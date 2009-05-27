#!/usr/bin/env ruby
# $Id: test.rb,v 1.2 2002/10/22 17:34:00 miles Exp $
# Driver does not carry cash.

$:.unshift '..'

require "RRD"

name = "test"
rrd = "#{name}.rrd"
start_time = Time.now.to_i
end_time = start_time.to_i + 300 * 300

puts "creating #{rrd}"
RRD.create(
    rrd,
    "--start", "#{start_time - 1}",
    "--step", "300",
	"DS:a:GAUGE:600:U:U",
    "DS:b:GAUGE:600:U:U",
    "RRA:AVERAGE:0.5:1:300")
puts

puts "updating #{rrd}"
start_time.step(end_time, 300) { |i|
    RRD.update(rrd, "#{i}:#{rand(100)}:#{Math.sin(i / 800) * 50 + 50}")
}
puts

puts "fetching data from #{rrd}"
(fstart, fend, data) = RRD.fetch(rrd, "--start", start_time.to_s, "--end", end_time.to_s, "AVERAGE")
puts "got #{data.length} data points from #{fstart} to #{fend}"
puts

puts "generating graph #{name}.png"
RRD.graph(
   "#{name}.png",
    "--title", " RubyRRD Demo", 
    "--start", "#{start_time+3600}",
    "--end", "start + 1000 min",
    "--interlace", 
    "--imgformat", "PNG",
    "--width=450",
    "DEF:a=#{rrd}:a:AVERAGE",
    "DEF:b=#{rrd}:b:AVERAGE",
    "CDEF:line=TIME,2400,%,300,LT,a,UNKN,IF",
    "AREA:b#00b6e4:beta",
    "AREA:line#0022e9:alpha",
    "LINE3:line#ff0000")
puts

# last method test
if end_time != RRD.last("#{rrd}").to_i
    puts "last method expects #{Time.at(end_time)}."
    puts "                But #{RRD.last("#{rrd}")} returns."
end
puts

print "This script has created #{name}.png in the current directory\n";
print "This demonstrates the use of the TIME and % RPN operators\n";
