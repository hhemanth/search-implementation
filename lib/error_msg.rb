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

  def config_file_doesnt_exist(index)
    "Config file for index #{index} is not present in the location specified"
  end

  def data_file_doesnt_exist(index)
    "Data file for index #{index} is not present in the location specified"
  end

  def config_file_not_json(index)
    "Config file for index #{index} is not a JSON"
  end

  def data_file_not_json(index)
    "Data file for index #{index} is not a JSON"
  end

  def mandatory_keys_missing_in_option
    "The following mandatory keys are missing in the options provided -> index_name, data_file, config_file"
  end

  def index_name_empty
    "index_name in one of the config is empty"
  end


end
