require 'pry'
require 'json'
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
      config_file = config_file_path(search_option)
      config = JSON.parse(File.read(config_file)).with_indifferent_access

      search_service_hash[search_index] = {
        data_file: data_file_path(search_option),
        config_file: config_file_path(search_option),
        one_to_one_reference_config: config[:schema][:one_to_one_reference_config],
        one_to_many_reference_config: config[:schema][:one_to_many_reference_config]
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
      doc_index = DocumentIndex.new(search_index, config)
      doc_index.index!(data)
      doc_indices_hash[search_index] = doc_index
    end
  end

  def search_global(term:nil)
    result = {}
    doc_indices_hash.keys.each do |index|
      result[index] = search(index: index, term: term)
    end
    result
  end


  def search(index:nil, attr:nil, term:nil)
    doc_index = doc_indices_hash[index]
    result = search_tokens(term).flat_map do |t|
      doc_index.search(attr: attr, val: t)
    end

    add_one_to_one_reference_entities(result, index: index)
    add_one_to_many_reference_entities(result, index: index)
    result
  end

  def add_one_to_many_reference_entities(result, index:)
    ref_config = search_service_hash[index][:one_to_many_reference_config]


    return unless ref_config
    ref_config.each do |ref_hash|
      cur_ref_id = ref_hash["reference_id"]
      cur_ref_entity = ref_hash["reference_entity"]
      res_ref_entity = ref_hash["result_term"]
      ref_index = doc_indices_hash[cur_ref_entity]
      next unless ref_index
      result.each do |r|
        r[res_ref_entity] = ref_index.search(attr: cur_ref_id, val: r["_id"])
      end
    end
  end
  #Annotates the search results
  def add_one_to_one_reference_entities(result, index:)
    ref_config = search_service_hash[index][:one_to_one_reference_config]
    return unless ref_config
    ref_config.each do |ref_hash|
      cur_ref_id = ref_hash["reference_id"]
      cur_ref_entity = ref_hash["reference_entity"]
      res_ref_entity = get_result_ref_entity(cur_ref_id)
      ref_index = doc_indices_hash[cur_ref_entity]
      next unless ref_index
      result.each do |r|
        r[res_ref_entity] = ref_index.get(r[cur_ref_id])
      end
    end
  end

  private

  def data_file_path(search_option)
    Dir::pwd + '/' + search_option[:data_file]
  end

  def config_file_path(search_option)
    Dir::pwd + '/' + search_option[:config_file]
  end

  def get_result_ref_entity(ref_id)
    ref_id.split("_id").first.capitalize
  end

  def search_tokens(input_text)
    return [''] if input_text.to_s.strip == ''
    (input_text.to_s).split(' ').map(&:downcase)
  end


end
