class ToolsController < ApplicationController
  
  def check_caimpaign
  	file = params[:csv_file]
  	name = params[:name]
  	if file.present?
  		phones = TestCaimpaignStatus.import_csv(file)
  		if phones.present?
  			caimpaign = TestCaimpaign.create(name: name)
  			if caimpaign.present?
	  			counter = 1
		  		TestCaimpaignStatus.delay(run_at: 10.seconds.from_now, queue: 'main').failed_phone_csv(phones, counter, caimpaign.id)
		  		redirect_to download_test_caimpaign_path
		  	end
	  	end
  	end
  end

  def export
  	test_caimpaign = params[:id]
    @data = TestCaimpaignStatus.where(test_caimpaign_id: test_caimpaign).order(:created_at)
    respond_to do |format|
      format.html { redirect_to root_url }
      format.csv { send_data @data.to_csv }
    end
  end

  def download_test_caimpaign
  	@test_caimpaigns = TestCaimpaign.all
  end
end
