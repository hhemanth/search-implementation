#stores, parses and validates Docuemnt config
# checkes if data file and config file is present and valid
# return tokenize_list & reference_config
require 'json'
class IndexSearchConfig
  attr_accessor :config, :search_config_hash, :errors
  def initialize(config)
    @config = config
    @errors = []
    @search_config_hash = {}
    parse_config
  end

  def valid?
    search_config_hash.keys.each do |index|
      config_file(index).present? && data_file(index).present?
    end
  end

  def parse_config
    config.each do |search_option|
      search_index = search_option[:index_name]
      config_file = config_file_path(search_option)
      iconfig = IConfig.new(index:search_index,
                  data_file: data_file_path(search_option) ,
                  config_file: config_file_path(search_option),
                  schema: JSON.parse(File.read(config_file)).with_indifferent_access)
      search_config_hash[search_index] = iconfig
    end
  end

  def config_file(index)
    cur_config(index).config_file
  end

  def data_file(index)
    cur_config(index).data_file
  end

  def schema_tokenize_list(index)
    cur_config(index).schema["tokenize_list"]
  end

  def one_to_one_reference_config(index)
    cur_config(index).one_to_one_reference_config
  end

  def one_to_many_reference_config(index)
    cur_config(index).one_to_many_reference_config
  end

  def config_file_path(search_option)
    Dir::pwd + '/' + search_option[:config_file]
  end

  def data_file_path(search_option)
    Dir::pwd + '/' + search_option[:data_file]
  end



  class IConfig
    attr_accessor :index, :data_file, :config_file, :schema
    def initialize(index:, data_file:, config_file:, schema:)
      @index = index
      @data_file = data_file
      @config_file = config_file
      @schema = schema["schema"]
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
  end

  private

  def cur_config(index)
    search_config_hash[index]
  end
end