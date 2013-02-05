# http://humdi.net/vnstat/man/vnstat.html

require 'sinatra'

TEMP_DIR = "#{File.dirname(__FILE__)}/tmp"
OUTPUT_MODES = ["hours", "days", "months", "top10", "summary", "hsummary", "vsummary"]
INTERFACES = [["em0", "Internet"], ["re0","Local network"], ["gif0", "IPv6"]]
CACHE_IMAGE = 5 # 5 minut (as cron)
URI_PATH_PREFIX = "/"

require "#{File.dirname(__FILE__)}/lib/helper.rb"
require "#{File.dirname(__FILE__)}/lib/controller.rb"

def interfaces
  INTERFACES.collect { |int|
    { :system => int.first,
      :alias => int.last,
      :user => "#{int.last} (#{int.first})"
     }
  }
end

def build_image_filename(interface, output_mode)
  return "#{TEMP_DIR}/vnstat-#{interface}-#{output_mode}.png"
end

def validate_interface_name(interface)
  return interfaces.collect{ |int| int[:system] }.include?(interface)
end

def validate_output_mode(output_mode)
  return OUTPUT_MODES.include?(output_mode)
end

def check_image_cache(interface,output_mode)
  output_file = build_image_filename(interface,output_mode)
  return false unless File.exists?(output_file)
  mtime = File.mtime(output_file)
  return (Time.now - mtime) < ((CACHE_IMAGE - (mtime.min % CACHE_IMAGE)) * 60) # expire cache in 0,5,10..
end

def generate_image_with_stats(interface, output_mode)
  output_file = build_image_filename(interface,output_mode)
  begin `vnstati -i #{interface} --#{output_mode} -o #{output_file}` rescue return false end
  $? == 0 ? output_file : false
end
