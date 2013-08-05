class AccountingController < ApplicationController
  before_filter :confirm_logged_in
  autocomplete :vendor, :trade
  
  def index
    render('receivables')
  end

  def receivables

  end
  
  def new_payment
    @payment =  Payment.new
  end

  def create_payment
    #Instantiate a new object using form parameters
    @account = Account.find(params[:account][:id])
    @payment = Payment.new(params[:payment])
    #save subject
    if @payment.save
      @account.payments << @payment
      #if save succeeds, redirect to list action
      redirect_to(:action => 'payables')
    else
      #if save fails, redisplay form to user can fix problems
      render('new_payment')
    end
  end
  
  def payment_history
    @payments = Payment.all
  end
  
  def view_payment
    
  end
  
  def edit_payment
    
  end
  
  def delete_payment
    
  end
  
  def destroy_payment
    
  end
  
  def show
    
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
