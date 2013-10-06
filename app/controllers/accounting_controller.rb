class AccountingController < ApplicationController
  before_filter :authenticate_user!
  
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
    create_purchasable(PurchaseOrder.name)
  end

  def edit_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
  end

  def update_purchase_order
    update_purchasable(PurchaseOrder.name)
  end

  def delete_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
  end

  def destroy_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
    @purchase_order.destroy
    redirect_to(:action => 'purchase_orders')
  end

  def add_item_to_purchasable
    @item = Item.find(params[:item_id])
    respond_to do |format|
      format.js {}
    end
  end

  def bills
    @bills = Bill.where("builder_id = ?", session[:builder_id]).order(:id)
  end

  def new_bill
    @bill = Bill.new
  end

  def create_bill
    create_purchasable(Bill.name)
  end

  def edit_bill
    @bill = Bill.find(params[:id])
  end

  def update_bill
    update_purchasable(Bill.name)
  end

  def delete_bill
    @bill = Bill.find(params[:id])
  end

  def destroy_bill
    @bill = Bill.find(params[:id])
    @bill.destroy
    redirect_to(:action => 'bills')
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
    klass =  params[:type].to_s.constantize
    @type = params[:type].to_s.underscore
    @purchasable = params[:id].present? ? klass.find(params[:id]) : klass.new
    @project = Project.find(params[@type.to_sym][:project_id])
    respond_to do |format|
      format.js {}
    end
  end

  def show_categories_template_items
    klass =  params[:type].to_s.constantize
    @type = params[:type].to_s.underscore
    @purchasable = params[:id].present? ? klass.find(params[:id]) : klass.new
    @categories_template = params[@type.to_sym][:categories_template_id].present? ? CategoriesTemplate.find(params[@type.to_sym][:categories_template_id]) : CategoriesTemplate.new
    respond_to do |format|
      format.js {}
    end
  end

  def autocomplete_vendor_name
    @vendors = Vendor.where("builder_id = ?", session[:builder_id]).search_by_name(params[:term]).order(:company)
    render :json => @vendors.map { |v|
      label = v.company.present? ? "#{v.company} <br/> <span class=\"autocomplete-sublabel\">#{v.full_name}</span>" : v.full_name
      {:id => v.id, :label => label, :value => v.display_name}
    }.to_json
  end

  private
  def create_purchasable(type)
    klass =  type.to_s.constantize
    @type = type.to_s.underscore
    @purchasable = klass.new(params[@type.to_sym])
    purchased_items = params[:items].select { |i| i[:id].nil? }
    amount_items = params[:items].select { |i| i[:actual_cost].present? && i[:id].present? }
    @purchasable.amount = amount_items
    @purchasable.builder_id = session[:builder_id]
    if @purchasable.save
      Item.where(:purchase_order_id => @purchasable.id).destroy_all
      @purchasable.items = Item.create(purchased_items)
      redirect_to(:action => "#{@type}s")
    else
      render("new_#{@type}")
    end
  end

  def update_purchasable(type)
    klass =  type.to_s.constantize
    @type = type.to_s.underscore
    @purchasable = klass.find(params[:id])
    purchased_items = params[:items].select { |i| i[:id].nil? }
    amount_items = params[:items].select { |i| i[:actual_cost].present? && i[:id].present? }
    @purchasable.amount = amount_items
    if @purchasable.update_attributes(params[@type.to_sym])
      Item.where("#{@type}_id".to_sym => @purchasable.id).destroy_all
      @purchasable.items = Item.create(purchased_items)
      redirect_to(:action => "#{@type}s")
    else
      render("new_#{@type}")
    end
  end
end
