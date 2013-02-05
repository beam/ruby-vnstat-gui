before do
  @selected_interface_filter = "all"
  @selected_output_mode_filter =  nil
  @page_title = "vnStat GUI"
end

get '/' do
  redirect filter_page_path_helper("all")
end

get '/web/all.html' do
  @page_title = "vnStat GUI - All interfaces"
  @selected_interfaces = interfaces
  erb :index, :layout => true
end

get '/web/:interface.html' do
  @page_title = "vnStat GUI - #{params[:interface]}"
  @selected_interfaces = [interfaces.detect { |int| int[:system] == params[:interface] }]
  erb :index, :layout => true
end

get '/web/:interface/:mode.html' do
  erb :index, :layout => true
end

get '/api/:interface.json' do
end

get '/img/:interface/:mode.png' do
  interface = params[:interface].downcase
  output_mode = params[:mode].downcase
  halt 415, "Unknown output mode" unless validate_output_mode(output_mode)
  halt 415, "Unknown interface" unless validate_interface_name(interface)
  output_file = check_image_cache(interface, output_mode) ? build_image_filename(interface,output_mode) : generate_image_with_stats(interface, output_mode)
  if output_file
    content_type 'image/png'
    send_file output_file
  else
    halt 503, "Image missing"
  end
end
