helpers do

  def truncate_string(string, max=350, end_string = ' ...')
    if string.nil? || string.length <= max
      return string
    else
      truncated_string = string.match( /(.{1,#{max - end_string.length}})(?:\s|\z)/ )[1]
      truncated_string << end_string
    end
  end

end
