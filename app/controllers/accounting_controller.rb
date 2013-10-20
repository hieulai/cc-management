class AccountingController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    render('receivables')
  end

  def receivables

  end

  def purchase_orders
    @purchase_orders = PurchaseOrder.where("builder_id = ?", session[:builder_id])
  end

  def new_purchase_order
    @purchase_order = PurchaseOrder.new
  end

  def create_purchase_order
    create_purchasable(PurchaseOrder.name)
  end

  def edit_purchase_order
    @purchasable = PurchaseOrder.find(params[:id])
  end

  def update_purchase_order
    update_purchasable(PurchaseOrder.name)
  end

  def delete_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
  end

  def destroy_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
    begin
      @purchase_order.destroy
      redirect_to(:action => 'purchase_orders')
    rescue ActiveRecord::ReadOnlyRecord
      @purchase_order.errors[:base] = "This record is Readonly"
      render :delete_purchase_order
    end
  end

  def add_item_to_purchasable
    @type = params[:type]
    @item = Item.find(params[:item_id])
    respond_to do |format|
      format.js {}
    end
  end

  def bills
    @bills = Bill.where("builder_id = ?", session[:builder_id])
  end

  def new_bill
    @bill = Bill.new
  end

  def create_bill
    create_purchasable(Bill.name)
  end

  def edit_bill
    @purchasable = Bill.find(params[:id])
  end

  def update_bill
    update_purchasable(Bill.name)
  end

  def delete_bill
    @bill = Bill.find(params[:id])
  end

  def destroy_bill
    @bill = Bill.find(params[:id])
    begin
      @bill.destroy
      redirect_to(:action => 'bills')
    rescue ActiveRecord::ReadOnlyRecord
      @bill.errors[:base] = "This record is Readonly"
      render :delete_bill
    end
  end

  def payments
    @payments = Payment.where("builder_id = ?", session[:builder_id])
  end

  def new_payment
    @payment =  Payment.new
    @bills = Array.new
  end

  def create_payment
    @payment = Payment.new(params[:payment])
    @payment.builder_id = session[:builder_id]
    if @payment.save
      redirect_to(:action => 'payments')
    else
      @bills = Array.new
      render('new_payment')
    end
  end
  
  def edit_payment
    @payment = Payment.find(params[:id])
    @bills = (@payment.bills + @payment.vendor.bills.unpaid).uniq
  end

  def update_payment
    @payment = Payment.find(params[:id])
    # Destroy all old payments_bills_attributes if vendor changed
    if params[:payment][:vendor_id].present? && params[:payment][:vendor_id] != @payment.vendor_id.to_s
      @payment.payments_bills.each do  |pb|
        params[:payment][:payments_bills_attributes] << {id: pb.id, _destroy: true}.with_indifferent_access
      end
    end
    if @payment.update_attributes(params[:payment])
      redirect_to(:action => 'payments')
    else
      @bills = (@payment.bills + @payment.vendor.bills.unpaid).uniq
      render('edit_payment')
    end
  end
  
  def delete_payment
    @payment = Payment.find(params[:id])
  end
  
  def destroy_payment
    @payment = Payment.find(params[:id])
    @payment.destroy
    redirect_to(:action => 'payments')
  end
  
  def show
    
  end
    

  def payables
    @payments = Payment.where("builder_id = ?", session[:builder_id]).limit(50)
    @bills = Bill.where("builder_id = ?", session[:builder_id]).limit(50)
    @purchase_orders = PurchaseOrder.where("builder_id = ?", session[:builder_id]).limit(50)
  end

  def payroll

  end
  
  def accounts

  end
  
  def reports

  end
  
  def import_export

  end

  def show_vendor_bills
    @bills = Array.new
    @payment = params[:payment_id].present? ? Payment.find(params[:payment_id]) : Payment.new
    if params[:payment].present? && params[:payment][:vendor_id].present?
      @vendor = Vendor.find params[:payment][:vendor_id]
      @bills = @vendor == @payment.vendor ? @vendor.bills : @vendor.bills.unpaid
    end
    respond_to do |format|
      format.js {}
    end
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
    begin
      if @purchasable.update_attributes(params[@type.to_sym])
        Item.where("#{@type}_id".to_sym => @purchasable.id).destroy_all
        @purchasable.items = Item.create(purchased_items)
        redirect_to(:action => "#{@type}s")
      else
        render("edit_#{@type}")
      end
    rescue ActiveRecord::ReadOnlyRecord
      @purchasable.errors[:base] = "This record is Readonly"
      render("edit_#{@type}")
    end
  end
end
