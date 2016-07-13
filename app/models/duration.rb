class Duration < ActiveRecord::Base

	def self.import_csv(file)
  	if file.present?
	  	sids = Array.new
	  	CSV.foreach(file.path, headers: true) do |row|
	  		sid = row[0]
	     	sids << sid  
	    end
	  end
    return sids
  end

	def self.call_duration(sids)
    if sids.present?
      nil_response_sids = Array.new
      sids.each do |s_id|
        if s_id.present?
          response = Exotel::Call.details(s_id) rescue false
          if response.present?
            start_time = response.start_time
            end_time = response.end_time
            duration = response.duration
            Duration.create(sid: s_id, start_time: start_time, end_time: end_time, duration: duration)
          else
            redo
          end
        else
          puts "sid is not present"
          
        end
      end
    end
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv.add_row column_names
      all.each do |webfile|
        values = webfile.attributes.values
        csv.add_row values
      end
    end
  end
end
