class AccountsController < ApplicationController
  before_filter :authenticate_user!

  def list
    @accounts = @builder.accounts.top
  end

  def show
    @account = @builder.accounts.find(params[:id])
    if params[:page]
      @balance = @account.balance({offset: (params[:page].to_i - 1) * Kaminari.config.default_per_page}).to_f
    else
      @balance = @account.balance.to_f
    end
    @transactions = @account.transactions.page params[:page]
  end

  def new
    @account =  @builder.accounts.new
  end

  def create
    @account = @builder.accounts.new(params[:account])
    if @account.save
      redirect_to(:action => 'list')
    else
      render('new')
    end
  end

  def edit
    @account = @builder.accounts.find(params[:id])
  end

  def update
    @account = @builder.accounts.find(params[:id])
    if @account.update_attributes(params[:account])
      redirect_to(:action => 'list')
    else
      render('edit')
    end
  end

  def delete
    @account = @builder.accounts.find(params[:id])
  end

  def destroy
    @account = @builder.accounts.find(params[:id])
    if @account.destroy
      redirect_to(:action => 'list')
    else
      render('delete')
    end
  end

  def reconcile
    @object = AccountingTransaction.find(params[:id])
    if @object
      @object.update_column(:reconciled, params["#{AccountingTransaction.name}_#{params[:id]}".to_sym].present?)
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
