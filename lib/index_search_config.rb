#This class stores and validates config for a Index
# It validates data file, config file and the contents of the config file
# It validates the following
# config_file is present
# data_file is present
# conifg file is valid json
# data file is valid json
# config file has needed keys
# data file is an array of hashes

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
    search_config_hash.each { |index, config| config.valid? }
    @errors << search_config_hash.flat_map { |index, config| config.errors }
    @errors.flatten!&.reject!(&:empty?)&.uniq!
    return @errors.empty?
  end

  def parse_config
    return unless valid?
    config.each do |search_option|
      next unless option_keys_valid?(search_option)
      search_index = search_option[:index_name]
      search_config_hash[search_index] = IConfig.new(search_option)
    end
  end

  def option_keys_valid?(option)
    if option.keys.map(&:to_s).sort != %w[config_file data_file index_name]
      @errors << mandatory_keys_missing_in_option
      return false

    end
    return true
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

    def initialize(index_name:, data_file:, config_file:)
      @index = index_name
      @data_file = data_file
      @config_file = config_file
      @errors = []
      parse_config if valid?
    end

    def parse_config
      config = JSON.parse(File.read(config_file)).with_indifferent_access
      @schema = config[:schema]
    end

    def valid?
      errors << index_name_empty if empty_or_nil?(index)
      return false unless errors.empty?
      errors << data_file_param_empty(index) if empty_or_nil?(data_file)
      return false unless errors.empty?
      errors << config_file_param_empty(index) if empty_or_nil?(config_file)
      return false unless errors.empty?
      errors << config_file_doesnt_exist(index) unless File.file?(config_file)
      return false unless errors.empty?
      errors << data_file_doesnt_exist(index) unless File.file?(data_file)
      return false unless errors.empty?
      errors << config_file_not_json(index) unless json_file?(config_file)
      return false unless errors.empty?
      errors << data_file_not_json(index) unless json_file?(data_file)

      return errors.empty?

    end

    def json_file?(f)
      begin
        JSON.parse(File.read(f))
        return true
      rescue JSON::ParserError => e
        return false
      end
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