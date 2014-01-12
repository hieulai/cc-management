class AccountsController < ApplicationController
  before_filter :authenticate_user!
  
  def list
    @accounts = Account.where("builder_id = ?", session[:builder_id])
  end
  
  def show
    @account = Account.find(params[:id])
  end
  
  def new
    @account =  Account.new
  end
  
  def create
    #Instantiate a new object using form parameters
    @builder = Base::Builder.find(session[:builder_id])
    @account = Account.new(params[:account])
    #save subject
    if @account.save
      @builder.accounts << @account
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

  def reconcile
    @type = params[:type].to_s
    @object = @type.constantize.find(params[:id])
    if @object
      @object.update_attribute(:reconciled, params["#{params[:type].to_s}_#{params[:id]}".to_sym].present?)
    end
    respond_to do |format|
      format.js
    end
  end
end
