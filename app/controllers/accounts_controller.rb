class AccountsController < ApplicationController
  before_filter :authenticate_user!
  
  def list
    @accounts = @builder.accounts
  end
  
  def show
    @account = Account.find(params[:id])
  end
  
  def new
    @account =  Account.new
  end
  
  def create
    @builder = Base::Builder.find(session[:builder_id])
    @account = Account.new(params[:account])
    @account.builder = @builder
    if @account.save
      redirect_to(:action => 'list')
    else
      render('new')
    end
  end
  
  def edit
    @account = Account.find(params[:id])
  end
  
  def update
    @account = Account.find(params[:id])
    if @account.update_attributes(params[:account])
      redirect_to(:action => 'list')
    else
      render('edit')
    end
  end
  
  def delete
    @account = Account.find(params[:id])
  end

  def destroy
    @account = Account.find(params[:id])
    if @account.destroy
      redirect_to(:action => 'list')
    else
      render('delete')
    end
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

  def new_transfer
    @transfer = Transfer.new
  end

  def create_transfer
    @transfer = Transfer.new(params[:transfer])
    if @transfer.save
      redirect_to(params[:original_url].presence ||url_for(:action => 'list'))
    else
      render('new_transfer')
    end
  end

  def edit_transfer
    @transfer = Transfer.find(params[:id])
  end

  def update_transfer
    @transfer = Transfer.find(params[:id])
    if @transfer.update_attributes(params[:transfer])
      redirect_to(params[:original_url].presence ||url_for(:action => 'list'))
    else
      render('edit_transfer')
    end
  end

  def delete_transfer
    @transfer = Transfer.find(params[:id])
  end

  def destroy_transfer
    @transfer = Transfer.find(params[:id])
    if @transfer.destroy
      redirect_to(:action => 'list')
    else
      render('delete_transfer')
    end
  end

  def show_transfer_accounts
    @transfer = params[:id].present? ? Transfer.find(params[:id]) : Transfer.new
    @transfer.kind = params[:transfer][:kind]

  end
end
