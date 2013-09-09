class AccountingController < ApplicationController
  before_filter :authenticate_user!
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

  def purchase_orders
    @purchase_orders = PurchaseOrder.where("builder_id = ?", session[:builder_id]).order(:id)
  end

  def new_purchase_order
    @purchase_order = PurchaseOrder.new
  end

  def create_purchase_order
    @purchase_order = PurchaseOrder.new(params[:purchase_order])
    purchased_items = params[:items].select { |i| i[:id].nil? }
    amount_items = params[:items].select { |i| i[:actual_cost].present? && i[:id].present? }
    @purchase_order.amount = amount_items
    @purchase_order.builder_id = session[:builder_id]
    if @purchase_order.save
      Item.where(:purchase_order_id => @purchase_order.id).destroy_all
      @purchase_order.items = Item.create(purchased_items)
      redirect_to(:action => 'purchase_orders')
    else
      render('new_purchase_order')
    end
  end

  def edit_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
  end

  def update_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
    purchased_items = params[:items].select { |i| i[:id].nil? }
    amount_items = params[:items].select { |i| i[:actual_cost].present? && i[:id].present? }
    @purchase_order.amount = amount_items
    if @purchase_order.update_attributes(params[:purchase_order])
      Item.where(:purchase_order_id => @purchase_order.id).destroy_all
      @purchase_order.items = Item.create(purchased_items)
      redirect_to(:action => 'purchase_orders')
    else
      render('edit_purchase_order')
    end
  end

  def delete_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
  end

  def destroy_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
    @purchase_order.destroy
    redirect_to(:action => 'purchase_orders')
  end

  def add_item_to_purchase_order
    @item = Item.find(params[:item_id])
    respond_to do |format|
      format.js {}
    end
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

  def show_project_categories_template
    @purchase_order = params[:id].present? ? PurchaseOrder.find(params[:id]) : PurchaseOrder.new
    @project = Project.find(params[:purchase_order][:project_id])
    respond_to do |format|
      format.js {}
    end
  end

  def show_categories_template_items
    @purchase_order = params[:id].present? ? PurchaseOrder.find(params[:id]) : PurchaseOrder.new
    @categories_template = params[:purchase_order][:categories_template_id].present? ? CategoriesTemplate.find(params[:purchase_order][:categories_template_id]) : CategoriesTemplate.new
    respond_to do |format|
      format.js {}
    end
  end
end
