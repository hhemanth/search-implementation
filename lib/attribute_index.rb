# Stores hash table where the key is a search term and value is the id of documents it is found in
# Each of the attributes in a Document has an Attribute Index.
# Consider the following Index (Document), index_name: Person
# [{"_id" => 1, "name" => "Hemanth Haridas", "age"=> 35, "occupation"=> "Software Engineer"},
#  {"_id" => 2, "name" => "Jack Straw", "age"=> 25, "occupation"=> "Senior Software Engineer"},
# ]
# Then the indexing will result in the following Attribute indexes
# AttributeIndex index_name: Person, attribute_name: name, attr_index: {"hemanth" => [1], "haridas"=>[1], "jack"=>[2], "straw"=>[2]}
# AttributeIndex index_name: Person, attribute_name: age, attr_index: {"35" => [1], "25"=>[2]}
# AttributeIndex index_name: Person, attribute_name: occupation, attr_index: {"software" => [1,2], "engineer"=>[1,2], "senior"=> [2]}
# AttributeIndex index_name: Person, attribute_name: id, attr_index: {"1" => [1], "2"=>[2]}
class AttributeIndex
  attr_accessor :index_name, :attribute_name, :attr_index

  def initialize(index_name, attribute_name)
    @index_name = index_name
    @attribute_name = attribute_name
    @attr_index = {}
  end

  def index!(attr_val, doc_index)

    attr_index[process(attr_val)] ||= []
    attr_index[process(attr_val)] << doc_index

  end

  def search(term)
    attr_index[process(term)]&.uniq || []
  end

  def process(q)
    q.to_s.downcase
  end

  def attr_values
    attr_index.keys
  end

end