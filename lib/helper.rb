def filter_page_path_helper(interface = nil,output_mode = nil)
  if output_mode == nil
    return "#{URI_PATH_PREFIX}web/#{interface}.html"
  else
    return "#{URI_PATH_PREFIX}web/#{interface}/#{output_mode}.html"
  end
end

def image_path_helper(interface, output_mode)
  return "#{URI_PATH_PREFIX}img/#{interface}/#{output_mode}.png"
end
