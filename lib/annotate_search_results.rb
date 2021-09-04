# This class is resposible for annotating search results
# Annotates one to one relations and one to many mapping
#
# *** One to One mapping
# For example if a hash has organization_id, then it adds a key value pair,
# Where key is "organization" value if the organization entity as a hash
#
#
# # *** One to Many mapping
# For example if there are 2 indices, Organization & User
# the User has organisation_id as a key
# and if the result is a Organization hash,
# Then it adds a "users" key which has value as a array
# each of the array elements is a User hash, where the User's organization_id is same as result's Organization's _id

class AnnotateSearchResults
  attr_accessor :doc_indices_hash, :search_config
  def initialize(doc_indices_hash, search_config)
    @doc_indices_hash = doc_indices_hash
    @search_config = search_config
  end

  def run!(result, index:)
    add_one_to_one_reference_entities(result, index: index)
    add_one_to_many_reference_entities(result, index: index)
  end

  def cur_config(index)
    search_config.cur_config(index)
  end

  def add_one_to_many_reference_entities(result, index:)
    ref_config = cur_config(index).one_to_many_reference_config

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
    ref_config = cur_config(index).one_to_one_reference_config
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
  def get_result_ref_entity(ref_id)
    ref_id.split("_id").first.capitalize
  end

end