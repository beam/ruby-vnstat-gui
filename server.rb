require 'sinatra'

TEMP_DIR = "#{File.dirname(__FILE__)}/tmp"
OUTPUT_MODES = ["hours", "days", "months", "top10", "summary", "hsummary", "vsummary"]
INTERFACES = ["em0", "re0", "gif0"]
CACHE_IMAGE = 5 # 5 minut (as cron)

def build_image_filename(interface, output_mode)
  return "#{TEMP_DIR}/vnstat-#{interface}-#{output_mode}.png"
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

before do
  @uri_path_prefix = '/'
end

get '/' do
  @page_title = "vnStat"
  erb :index, :layout => true
end

get '/img/:interface/:mode.png' do
  interface = params[:interface].downcase
  output_mode = params[:mode].downcase
  halt 415, "Unknown output mode" unless OUTPUT_MODES.include?(output_mode)
  halt 415, "Unknown interface" unless INTERFACES.include?(interface)
  output_file = check_image_cache(interface, output_mode) ? build_image_filename(interface,output_mode) : generate_image_with_stats(interface, output_mode)
  if output_file
    content_type 'image/png'
    send_file output_file
  else
    halt 503, "Image missing"
  end
end
