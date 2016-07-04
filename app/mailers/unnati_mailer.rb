class UnnatiMailer < ActionMailer::Base
  default from: "Unnati Alert <alerts@unnatihelpers.com>"
    
  #message
  def system_notification(message,group=nil)
    @message = message
    #environment
    if Rails.env == "production"
      server_type = "live"
    else
      server_type = Rails.env
    end
    
    case group
    when "Admin"
      email_addresses = "aashutosh@unnatihelpers.com"
    when "Developer"
      email_addresses = "un4@unnatihelpers.com"
    when "Manager"
      email_addresses = "shantanu@unnatihelpers.com,ravi@unnatihelpers.com,diya@unnatihelpers.com"
    when "Interview"
      email_addresses = "shantanu@unnatihelpers.com,ravi@unnatihelpers.com,diya@unnatihelpers.com,un6@unnatihelpers.com"
    when "Sourcing"
      email_addresses = "shantanu@unnatihelpers.com,ravi@unnatihelpers.com,diya@unnatihelpers.com,princi@unnatihelpers.com,monika@unnatihelpers.com,ved@unnatihelpers.com,un1@unnatihelpers.com,un2@unnatihelpers.com,un3@unnatihelpers.com"
    else
      email_addresses = "shantanu@unnatihelpers.com,ravi@unnatihelpers.com"
    end
    
    mail(to: email_addresses, subject: server_type.to_s + " : Message")
  end
end