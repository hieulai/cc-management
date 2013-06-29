class AccountingController < ApplicationController
  before_filter :confirm_logged_in
  
  def index
    render('receivables')
  end

  def receivables

  end

  def payables

  end

  def payroll

  end
  
  def accounts

  end
  
  def reports

  end
  
  def import_export

  end
  
  
end
