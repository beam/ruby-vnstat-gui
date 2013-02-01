require 'sinatra'

TEMP_DIR = "#{File.dirname(__FILE__)}/tmp"
OUTPUT_MODES = ["hours", "days", "months", "top10", "summary", "hsummary", "vsummary"]
INTERFACES = ["em0", "re0", "giff0"]

get '/' do
  "Hello World!"
end

get '/img/:interface/:mode.png' do
  interface = params[:interface].downcase
  output_mode = params[:mode].downcase
  halt 415, "Unknown output mode" unless OUTPUT_MODES.include?(output_mode)
  halt 415, "Unknown interface" unless INTERFACES.include?(interface)
  # content_type 'image/png'
  # `vnstati -m -i em0 -o -`
  generate_image(interface, output_mode)
end

def generate_image(interface, output_mode)
  "vnstati -i #{interface} --#{output_mode} -o #{TEMP_DIR}/vnstat-#{interface}-#{output_mode}.png"
end