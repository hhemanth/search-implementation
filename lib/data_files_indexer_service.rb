require 'pry'
require_relative './document_index'
class DataFilesIndexerService
  attr_accessor :search_options, :search_service_hash, :doc_indices_hash

  def initialize(search_options)
    @search_options = search_options
    @search_service_hash = {}
    @doc_indices_hash = {}
    parse_search_options
  end

  def parse_search_options
    search_options.each do |search_option|
      search_index = search_option[:index_name]
      search_service_hash[search_index] = {
          data_file: Dir::pwd + '/' + search_option[:data_file],
          config_file: Dir::pwd + '/' + search_option[:config_file]
      }
    end
  end

  def indices
    search_service_hash.keys
  end

  def attributes(index)
    doc_index = doc_indices_hash[index]
    doc_index.attributes
  end

  def attribute_values(index, attr)
    doc_index = doc_indices_hash[index]
    doc_index.values_for_attr(attr)
  end

  def index_data_files!
    search_service_hash.each do |search_index, search_params|
      data_file = search_params[:data_file]
      data = JSON.parse(File.read(data_file))
      config_file = search_params[:config_file]
      config = JSON.parse(File.read(config_file)).with_indifferent_access
      doc_index = DocumentIndex.new(search_index,config)
      doc_index.index!(data)
      # puts pastel.cyan("Indexing #{search_index}")
      # progress_bar
      doc_indices_hash[search_index] = doc_index
    end
  end

  def search(options)
    index_name = options[:index]
    attr = options[:attr]
    term = options[:value]
    index = doc_indices_hash[index_name]
    index.search(attr: attr, val: term)
  end


end