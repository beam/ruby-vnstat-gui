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
