
# Handles sending HTTP responses to clients
module Responses
  FILE_EXTENSION_CONTENT_TYPES = {
    '.js' => 'application/javascript',
    '.css' => 'text/css',
    '.html' => 'text/html'
  }

  RETURN_CODES = {
    :ok => '200 OK',
    :not_found => '404 Not Found'
  }

  class << self
    def send_ok_response(file_path, socket)
      file_contents = get_file_contents(file_path)
      content_type = FILE_EXTENSION_CONTENT_TYPES[File.extname(file_path)]
      send_response(file_contents, content_type, :ok, socket)
    end

    def send_not_found_response(socket)
      send_response(nil, nil, :not_found, socket)
    end

    private

    def get_file_contents(file_path)
      file_contents = ''
      File.open(file_path) do |file|
        file_contents = file.read
      end
      file_contents
    end

    def send_response(content_str, content_type, response_code, socket)
      header = <<~HEADER
        HTTP/1.1 #{RETURN_CODES[response_code]}
        Date: #{DateTime.now.rfc2822}
      HEADER

      unless content_type.nil?
        header += "Content-Type: #{content_type}; charset=utf-8\n"
      end

      unless content_str.nil?
        header += "Content-Length: #{content_str.size}\n"
      end

      if content_str.nil? && content_type.nil?
        socket.write header
        return
      else
        header += "\n"
      end

      content_body = <<~BODY
        #{content_str}
      BODY

      socket.write(header + content_body)
    end
  end
end
