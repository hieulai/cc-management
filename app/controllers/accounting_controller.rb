class AccountingController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    redirect_to(:action => 'receivables')
  end

  def receivables
    @invoices = Invoice.where("builder_id = ?", session[:builder_id]).limit(50)
    @receipts = Receipt.where("builder_id = ?", session[:builder_id]).limit(50)
    @deposits = Deposit.where("builder_id = ?", session[:builder_id]).limit(50)
  end

  def deposits
    @deposits = Deposit.where("builder_id = ?", session[:builder_id])
  end

  def new_deposit
    @deposit = Deposit.new
    @receipts = Receipt.unbilled
  end

  def create_deposit
    @deposit = Deposit.new(params[:deposit])
    @deposit.builder_id = session[:builder_id]
    if @deposit.save
      redirect_to(:action => 'receivables')
    else
      @receipts = Receipt.unbilled
      render('new_deposit')
    end
  end

  def edit_deposit
    @deposit = Deposit.find(params[:id])
    @receipts = (@deposit.receipts + Receipt.unbilled).uniq
  end

  def update_deposit
    @deposit = Deposit.find(params[:id])
    # Destroy all old deposits_receipts_attributes if account changed
    if params[:deposit][:client_id].present? && params[:deposit][:client_id] != @deposit.client_id.to_s
      @deposit.deposits_receipts.each do  |dr|
        params[:deposit][:deposits_receipts_attributes] << {id: dr.id, _destroy: true}.with_indifferent_access
      end
    end
    if @deposit.update_attributes(params[:deposit])
      redirect_to(:action => 'receivables')
    else
      @receipts = (@deposit.receipts + @deposit.account.receipts.unbilled).uniq
      render('edit_deposit')
    end
  end

  def delete_deposit
    @deposit = Deposit.find(params[:id])
  end

  def destroy_deposit
    @deposit = Deposit.find(params[:id])
    @deposit.destroy
    redirect_to(:action => "receivables")
  end

  def receipts
    @receipts = Receipt.where("builder_id = ?", session[:builder_id])
  end

  def new_receipt
    @receipt = Receipt.new
    @invoices = Array.new
  end

  def create_receipt
    @receipt = Receipt.new(params[:receipt])
    @receipt.builder_id = session[:builder_id]
    if @receipt.save
      redirect_to(:action => 'receivables')
    else
      @invoices = Array.new
      render('new_receipt')
    end
  end

  def edit_receipt
    @receipt = Receipt.find(params[:id])
    @invoices = (@receipt.invoices + @receipt.client.invoices.unbilled).uniq
  end

  def update_receipt
    @receipt = Receipt.find(params[:id])
    # Destroy all old receipts_invoices_attributes if client changed
    if params[:receipt][:client_id].present? && params[:receipt][:client_id] != @receipt.client_id.to_s
      @receipt.receipts_invoices.each do  |ri|
        params[:receipt][:receipts_invoices_attributes] << {id: ri.id, _destroy: true}.with_indifferent_access
      end
    end
    if @receipt.update_attributes(params[:receipt])
      redirect_to(:action => 'receivables')
    else
      @invoices = (@receipt.invoices + @receipt.client.invoices.unbilled).uniq
      render('edit_receipt')
    end
  end

  def delete_receipt
    @receipt = Receipt.find(params[:id])
  end

  def destroy_receipt
    @receipt = Receipt.find(params[:id])
    if @receipt.destroy
      redirect_to(:action => "receivables")
    else
      render :delete_receipt
    end
  end

  def invoices
    @invoices = Invoice.where("builder_id = ?", session[:builder_id])
  end

  def invoice
    @invoice = Invoice.find(params[:id])
    respond_to do |format|
      format.pdf do
        render :pdf => "Invoice-#{@invoice.id}",
               :layout => 'pdf.html',
               #:show_as_html => true, // for debugging html & css
               :footer => {:center => 'Page [page]'}
      end
    end
  end

  def invoice_email
    @invoice = Invoice.find(params[:id])
  end

  def send_invoice_email
    @invoice = Invoice.find(params[:id])
    Mailer.delay.send_invoice(params[:to], params[:subject], params[:body], @invoice)
    redirect_to :action => 'invoice_email', :id => @invoice.id, :notice => "Email was sent."
  end

 def new_invoice
    @invoice = Invoice.new
 end

  def create_invoice
    @invoice = Invoice.new(params[:invoice])
    @invoice.builder_id = session[:builder_id]
    if @invoice.save
      redirect_to(:action => 'receivables')
    else
      render('new_invoice')
    end
  end

  def edit_invoice
    @invoice = Invoice.find(params[:id])
  end

  def update_invoice
    @invoice = Invoice.find(params[:id])
    # Destroy all old invoices_items_attributes if estimate changed
    if params[:invoice][:estimate_id].present? && params[:invoice][:estimate_id] != @invoice.estimate_id.to_s
      @invoice.invoices_items.each do  |ii|
        params[:invoice][:invoices_items_attributes] << {id: ii.id, _destroy: true}.with_indifferent_access
      end
    end
    if @invoice.update_attributes(params[:invoice])
      redirect_to(:action => 'receivables')
    else
      render('edit_invoice')
    end
  end

  def delete_invoice
    @invoice = Invoice.find(params[:id])
  end

  def destroy_invoice
    @invoice = Invoice.find(params[:id])
    if @invoice.destroy
      redirect_to(:action => "receivables")
    else
      render :delete_invoice
    end
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
    if @purchase_order.destroy
      redirect_to(:action => "payables")
    else
      render :delete_purchase_order
    end
  end

  def add_item_to_purchasable
    @type = params[:type]
    @item = Item.find(params[:item_id]) if params[:item_id].present?
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
    if @bill.destroy
      redirect_to(:action => "payables")
    else
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
      redirect_to(:action => "payables")
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
      redirect_to(:action => "payables")
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
    redirect_to(:action => "payables")
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

  def show_estimate_items
    @invoice = params[:invoice_id].present? ? Invoice.find(params[:invoice_id]) : Invoice.new
    if params[:invoice].present? && params[:invoice][:estimate_id].present?
      @estimate = Estimate.find(params[:invoice][:estimate_id])
    end
    respond_to do |format|
      format.js {}
    end
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

  def show_account_receipts
    @receipts = Array.new
    @deposit = params[:deposit_id].present? ? Deposit.find(params[:deposit_id]) : Deposit.new
    if params[:deposit].present? && params[:deposit][:account_id].present?
      @account = Account.find params[:deposit][:account_id]
      @receipts = @account == @deposit.account ? @account.receipts : @account.receipts.unbilled
    end
    respond_to do |format|
      format.js {}
    end
  end

  def show_client_invoices
    @invoices = Array.new
    @receipt = params[:receipt_id].present? ? Receipt.find(params[:receipt_id]) : Receipt.new
    if params[:receipt].present? && params[:receipt][:client_id].present?
      @client = Client.find params[:receipt][:client_id]
      @invoices = @client == @receipt.client ? @client.invoices : @client.invoices.unbilled
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
    purchased_items = params[:items].present? ? params[:items].select { |i| i[:id].nil? } : []
    amount_items = params[:items].present? ? params[:items].select { |i| i[:actual_cost].present? && i[:id].present? } : []
    @purchasable.amount = amount_items
    @purchasable.builder_id = session[:builder_id]
    # Checking for valid payment
    if @purchasable.instance_of? Bill
      if params[:bill][:create_payment] == "1"
        payment = Payment.new(params[:payment].merge(:builder_id => session[:builder_id],
                                                      :vendor_id => @purchasable.vendor_id,
                                                      :date => @purchasable.due_date))
        unless payment.valid?
          @bill = @purchasable
          payment.errors.full_messages.each do |m|
            @bill.errors[:base] << "Payment: #{m}"
          end
          render("new_bill")
          return
        end
      end
    end

    if @purchasable.save
      Item.where(:purchase_order_id => @purchasable.id).destroy_all
      @purchasable.items = Item.create(purchased_items)
      # Create payment simultaneously for bills
      if @purchasable.instance_of?(Bill) && payment && payment.save
        payment.payments_bills.create(bill_id: @purchasable.id, amount: @purchasable.total_amount)
      end
      redirect_to(:action => "payables")
    else
      @bill = @purchasable
      render("new_#{@type}")
    end
  end

  def update_purchasable(type)
    klass = type.to_s.constantize
    @type = type.to_s.underscore
    @purchasable = klass.find(params[:id])
    purchased_items = params[:items].present? ? params[:items].select { |i| i[:id].nil? } : []
    amount_items = params[:items].present? ? params[:items].select { |i| i[:actual_cost].present? && i[:id].present? } : []
    @purchasable.amount = amount_items
    if @purchasable.update_attributes(params[@type.to_sym])
      Item.where("#{@type}_id".to_sym => @purchasable.id).destroy_all
      @purchasable.items = Item.create(purchased_items)
      redirect_to(:action => "payables")
    else
      render("edit_#{@type}")
    end
  end
end
