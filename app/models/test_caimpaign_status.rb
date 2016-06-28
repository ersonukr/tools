class TestCaimpaignStatus < ActiveRecord::Base
	belongs_to :test_caimpaign

	def self.import_csv(file)
  	if file.present?
	  	phones = Array.new
	  	CSV.foreach(file.path, headers: true) do |row|
	  		phone = "0" << row[0]
	     	phones << phone  
	    end
	  end
    return phones
  end

  def self.connect_phones(phones)
  	if phones.present?
  		s_ids = Array.new
      phones.each do |phone|
        sleeping_time = nil
        time = Time.now.hour
        case time
        when (8..20)
          sleeping_time = 0
        when (21..23)
          sleeping_time = (Time.now + 1.day).change({:hour => 8, :minute => 00}) - Time.now
        when (0..7)
          sleeping_time = Time.now.change({:hour => 8, :minute => 00}) - Time.now
        end
        sleep(sleeping_time)
        connect_call = Exotel::Call.connect_to_flow(:to => '01139585681', :from => phone, :caller_id => '01139585221', :call_type => 'trans', :flow_id => '100379')
        if connect_call.present?
          s_ids << connect_call.sid
        else
          message = "Exotel is not responding for 100379 app"
          UnnatiMailer.delay(run_at: 10.seconds.from_now, queue: 'email').system_notification(message,"Admin")
        end
  		end
  		return s_ids
  	end	
  end

  def self.check_failed_phones(sids, counter, caimpaign)
  	if sids.present?
  		failed_phones = Array.new
  		sids.each do |s_id|
	  		if s_id.present?
					response = Exotel::Call.details(s_id)
					if response.present?
						phone = response.from rescue nil
						status = response.status rescue nil
						date_created = response.date_created rescue nil
						TestCaimpaignStatus.create(sid: s_id, phone: phone, status: status, attempt_no: counter, sid_created_at: date_created, test_caimpaign_id: caimpaign)
						if status == "failed"
							failed_phones << phone
						end
					else
						message = "Exotel response is not present for #{s_id}"
	        	UnnatiMailer.delay(run_at: 10.seconds.from_now, queue: 'email').system_notification(message,"Admin")
					end
				else
					message = "sid is not present"
	        UnnatiMailer.delay(run_at: 10.seconds.from_now, queue: 'email').system_notification(message,"Admin")
				end
	  	end
	  	return failed_phones
  	end
  end

  def self.failed_phone_csv(phones, counter, caimpaign)
  	if phones.present?
  		s_ids = TestCaimpaignStatus.connect_phones(phones)
  		sleep(2.minutes)
  		failed_phones = TestCaimpaignStatus.check_failed_phones(s_ids,counter,caimpaign)
  		until counter == 10
  			if failed_phones.present?
  				counter += 1
  				s_ids = TestCaimpaignStatus.connect_phones(failed_phones)
			  	sleep(2.minutes)
			  	failed_phones = TestCaimpaignStatus.check_failed_phones(s_ids,counter, caimpaign)
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
