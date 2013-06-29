class AccountsController < ApplicationController
  before_filter :confirm_logged_in
  
  def list
    @accounts = Account.all
  end
  
  def show
    @account = Account.find(params[:id])
  end
  
  def new
    @account =  Account.new
  end
  
  def create
    #Instantiate a new object using form parameters
    @account = Account.new(params[:account])
    #save subject
    if @account.save
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end
  
  def edit
    @account = Account.find(params[:id])
  end
  
  def update
    #Find object using form parameters
    @account = Account.find(params[:id])
    #Update subject
    if @account.update_attributes(params[:account])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end
  
  def delete
    @account = Account.find(params[:id])
  end

  def destroy
    Account.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end
end
