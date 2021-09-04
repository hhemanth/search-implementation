#stores, parses and validates Docuemnt config
# checkes if data file and config file is present and valid
# return tokenize_list & reference_config
require 'json'
require 'active_support'
require_relative './error_msg'

class IndexSearchConfig
  include ErrorMsg

  attr_accessor :config, :search_config_hash, :errors
  def initialize(config)
    @config = config
    @errors = []
    @search_config_hash = {}
    parse_config
  end

  def indices
    search_config_hash.keys
  end

  def valid?
    return false if @errors.size > 0
    if !config.is_a?(Array)
      @errors << config_incorrect_format
    end
    search_config_hash.each {|index, config| config.valid?}
    @errors << search_config_hash.flat_map{|index, config| config.errors}
    @errors.flatten!&.reject!(&:empty?)&.uniq!
    return @errors.empty?
  end

  def parse_config
    return unless valid?
    config.each do |search_option|
      search_index = search_option[:index_name]
      if search_option[:config_file].empty?
        @errors << config_file_param_empty(search_index)
        next
      end
      config_file = config_file_path(search_option)
      begin
        iconfig = IConfig.new(index:search_index,
                    data_file: data_file_path(search_option) ,
                    config_file: config_file_path(search_option),
                    schema: JSON.parse(File.read(config_file)).with_indifferent_access)
        search_config_hash[search_index] = iconfig
      rescue JSON::ParserError => e
        @errors << config_file_incorrect_format(search_index)
      end

    end
  end

  def config_file(index)
    cur_config(index).config_file
  end

  def data_file(index)
    cur_config(index).data_file
  end

  def schema_tokenize_list(index)
    cur_config(index).tokenize_list
  end

  def one_to_one_reference_config(index)
    cur_config(index).one_to_one_reference_config
  end

  def one_to_many_reference_config(index)
    cur_config(index).one_to_many_reference_config
  end

  def config_file_path(search_option)
    return search_option[:config_file] if empty_or_nil?(search_option[:config_file])
    Dir::pwd + '/' + search_option[:config_file]
  end

  def data_file_path(search_option)
    return search_option[:data_file] if empty_or_nil?(search_option[:data_file])
    Dir::pwd + '/' + search_option[:data_file]
  end

  def cur_config(index)
    search_config_hash[index]
  end

  def empty_or_nil?(f)
    f.nil? || f == ''
  end

  class IConfig
    include ErrorMsg
    attr_accessor :index, :data_file, :config_file, :schema, :errors
    def initialize(index:, data_file:, config_file:, schema:)
      @index = index
      @data_file = data_file
      @config_file = config_file
      @schema = schema["schema"]
      @errors = []
      @is_valid = true
    end

    # config_file is present
    # data_file is present
    # conifg file is valid json
    # data file is valid json
    # config file has needed keys
    # data file is an array of hashes
    def valid?
      if empty_or_nil?(data_file)
        errors << data_file_param_empty(index)
      end
      # if empty_or_nil?(config_file)
      #   errors << "Config file parameter for index #{index} is an empty string"
      # end

      # if file_present?(config_file)
      #   errors << "Config file for index #{index} is not present"
      # end
      #
      # if file_present?(data_file)
      #   errors << "Config file for index #{index} is not present"
      # end
      #
      # if json_file?(config_file)
      #   errors << "Config file for index #{index} is not in the correct format, not a json file"
      # end
      #
      # if config_file_correct_format?
      #   errors << "Config file for index #{index} is not in the correct format, Does not have the required keys"
      # end
      return errors.empty?

    end

    def tokenize_list
      schema["tokenize_list"]
    end

    def one_to_many_reference_config
      schema["one_to_many_reference_config"]
    end

    def one_to_one_reference_config
      schema["one_to_one_reference_config"]
    end

    private

    def empty_or_nil?(f)
      f.nil? || f == ''
    end
  end


end