require 'sinatra'

TEMP_DIR = "#{File.dirname(__FILE__)}/tmp"
OUTPUT_MODES = ["hours", "days", "months", "top10", "summary", "hsummary", "vsummary"]
INTERFACES = ["em0", "re0", "gif0"]

get '/' do
  erb :index, :layout => true
end

get '/img/:interface/:mode.png' do
  interface = params[:interface].downcase
  output_mode = params[:mode].downcase
  halt 415, "Unknown output mode" unless OUTPUT_MODES.include?(output_mode)
  halt 415, "Unknown interface" unless INTERFACES.include?(interface)
  output_file = generate_image_with_stats(interface, output_mode)
  if output_file
    content_type 'image/png'
    send_file output_file
  else
    halt 503, "Image missing"
  end
end

def generate_image_with_stats(interface, output_mode)
  output_file = "#{TEMP_DIR}/vnstat-#{interface}-#{output_mode}.png"
  begin `vnstati -i #{interface} --#{output_mode} -o #{output_file}` rescue return false end
  $? == 0 ? output_file : false
end