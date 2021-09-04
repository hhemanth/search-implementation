module ErrorMsg
  def data_file_param_empty(index)
    "Data file parameter for index #{index} is an empty string"
  end

  def config_file_param_empty(index)
    "Config file parameter for index #{index} is an empty string"
  end

  def config_file_incorrect_format(index)
    "Config file provided for index #{index} is not a JSON file"
  end

  def config_incorrect_format
    "config provided is not in the correct format. It should be an array of hashes"
  end
end
