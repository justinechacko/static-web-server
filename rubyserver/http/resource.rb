require_relative 'config'

# This object will help us figure out where and what the requested resource is.
class Resource
  attr_reader :request, :config, :mime_types

  def initialize(request, config, mime_types)
    @request = request
    @config = config
    @mime_types = mime_types
  end

  def resolve

    if @config.script_alias(@request.uri) 
      @absolute_path = @config.script_alias(@request.uri)

    elsif @config.alias(@request.uri)
      @absolute_path = @config.alias(@request.uri)

    else 
      @absolute_path = @config.document_root() + @request.uri
    end

    if @request.extension != '' and @mime_types.for(@request.extension) != nil
      return @absolute_path
    end

    # if we have not returned yet, the URI is almost certainly a directory.
    if not @absolute_path.end_with? "/" and File.directory?(@absolute_path+'/')
      @absolute_path += '/'
    end
    
    directory_indexes = @config.directory_indexes()
    directory_indexes.each do |directory_index|
      if(File.exist?(@absolute_path+directory_index))
        @absolute_path += directory_index # append the directory index
        break
      end
    end

    return @absolute_path
  end
end
