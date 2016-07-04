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
      not_connected_phone = Array.new
      phone_counter = 0
      loop_start_time = Time.now
      phones.each do |phone|
        phone_counter += 1
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
        if phone_counter == 100
          loop_end_time = Time.now
          duration = loop_end_time - loop_start_time
          if duration <= 60
            sleeping_duration = nil
            sleeping_duration = 60 - duration
            sleep(sleeping_duration)
            phone_counter = nil 
            loop_start_time = Time.now
          end
        end
        sleep(sleeping_time)
        connect_call = Exotel::Call.connect_to_flow(:to => '01139585681', :from => phone, :caller_id => '01139585221', :call_type => 'trans', :flow_id => '100379') rescue false
        if connect_call.present?
          s_id = connect_call.sid rescue nil
          if s_id.present?
            s_ids << s_id
          else
            message = "Exotel did not generate sid for this #{phone} number"
            UnnatiMailer.delay(run_at: 10.seconds.from_now, queue: 'email').system_notification(message,"Developer")
          end
        else
          not_connected_phone << phone
        end
  		end
      if phones.count != s_ids.count
        message = "sid is not generated for all phones and not connected phones is #{not_connected_phone}"
        UnnatiMailer.delay(run_at: 10.seconds.from_now, queue: 'email').system_notification(message,"Developer")
      end
  		return s_ids
  	end	
  end

  def self.check_failed_phones(sids, counter, caimpaign)
  	if sids.present?
  		failed_phones = Array.new
      nil_response_sids = Array.new
      sids_counter = 0
      loop_start_time = Time.now
  		sids.each do |s_id|
	  		if s_id.present?
          sids_counter += 1
          if sids_counter == 100
            loop_end_time = Time.now
            duration = loop_end_time - loop_start_time
            if duration <= 60
              sleeping_duration = nil
              sleeping_duration = 60 - duration
              sleep(sleeping_duration)
              sids_counter = nil 
              loop_start_time = Time.now
            end
          end
					response = Exotel::Call.details(s_id) rescue false
					if response.present?
						phone = response.from rescue nil
						status = response.status rescue nil
						date_created = response.date_created rescue nil
						TestCaimpaignStatus.create(sid: s_id, phone: phone, status: status, attempt_no: counter, sid_created_at: date_created, test_caimpaign_id: caimpaign)
						if status == "failed"
							failed_phones << phone
						end
					else
            nil_response_sids << s_id
					end
				else
					message = "sid is not present"
	        UnnatiMailer.delay(run_at: 10.seconds.from_now, queue: 'email').system_notification(message,"Developer")
				end
	  	end
      if nil_response_sids.present?
        message = "Exotel response is not present for these sids #{nil_response_sids}"
        UnnatiMailer.delay(run_at: 10.seconds.from_now, queue: 'email').system_notification(message,"Developer")
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
