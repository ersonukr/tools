class ToolsController < ApplicationController
  
  def check_caimpaign
  	file = params[:csv_file]
  	name = params[:name]
    password = params[:password]
    if password == "testcaimpaign@unnatihelpers"
      if file.present?
        phones = TestCaimpaignStatus.import_csv(file)
        if phones.present?
          caimpaign = TestCaimpaign.create(name: name)
          if caimpaign.present?
            counter = 1
            TestCaimpaignStatus.failed_phone_csv(phones, counter, caimpaign.id)
            redirect_to download_test_caimpaign_path
          end
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

  def check_call_duration
    file = params[:csv_file]
    if file.present?
      sids = Duration.import_csv(file)
      if sids.present?
        Duration.call_duration(sids)
        redirect_to download_call_duration_path
      end
    end
  end

  def download_call_duration
    @call_duration = Duration.all
  end

  def export_call_duration
    @data = Duration.order(:created_at)
    respond_to do |format|
      format.html { redirect_to download_call_duration_path }
      format.csv { send_data @data.to_csv }
    end
  end
end
