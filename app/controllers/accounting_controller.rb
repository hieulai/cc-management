class AccountingController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    redirect_to(:action => 'payables')
  end

  def receivables
  end

  def deposits
    @deposits = Deposit.where("builder_id = ?", session[:builder_id])
  end

  def new_deposit
    @deposit = Deposit.new
  end

  def create_deposit
    @deposit = Deposit.new(params[:deposit])
    @deposit.builder_id = session[:builder_id]
    if @deposit.save
      redirect_to(params[:original_url].presence ||url_for(:action => 'deposits'))
    else
      render('new_deposit')
    end
  end

  def edit_deposit
    @deposit = Deposit.find(params[:id])
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
      redirect_to(:action => 'deposits')
    else
      render('edit_deposit')
    end
  end

  def delete_deposit
    @deposit = Deposit.find(params[:id])
  end

  def destroy_deposit
    @deposit = Deposit.find(params[:id])
    @deposit.destroy
    redirect_to(:action => "deposits")
  end

  def receipts
    @receipts = Receipt.where("builder_id = ?", session[:builder_id])
  end

  def new_receipt
    @receipt = Receipt.new
  end

  def create_receipt
    @receipt = Receipt.new(params[:receipt])
    @receipt.builder_id = session[:builder_id]

    if params[:receipt][:create_deposit] == "1"
      deposit = Deposit.new(params[:deposit].merge(:builder_id => session[:builder_id]))
      unless deposit.valid?
        @receipt.errors[:base] << "Deposit information invalid: <br/> #{deposit.errors.full_messages.join("<br/>")}"
        respond_to do |format|
          format.html { render("new_receipt") }
          format.js { render "receipt_response" }
        end
        return
      end
      @receipt.received_at ||= deposit.date
    end

    if @receipt.save
      deposit.deposits_receipts.create(receipt_id: @receipt.id, amount: @receipt.amount) if deposit && deposit.save
      respond_to do |format|
        format.html { redirect_to(params[:original_url].presence ||url_for(:action => 'receipts')) }
        format.js { render :js => "window.location = '#{ params[:original_url].presence ||url_for(:action => "receipts")}'" }
      end
    else
      respond_to do |format|
        format.html { render('new_receipt') }
        format.js { render "receipt_response" }
      end
    end
  end

  def edit_receipt
    @receipt = Receipt.find(params[:id])
  end

  def update_receipt
    @receipt = Receipt.find(params[:id])
    # Destroy all old receipts_invoices_attributes if client changed
    if params[:receipt][:client_id].present? && params[:receipt][:client_id] != @receipt.client_id.to_s
      @receipt.receipts_invoices.each do |ri|
        params[:receipt][:receipts_invoices_attributes] << {id: ri.id, _destroy: true}.with_indifferent_access
      end
    end
    if @receipt.update_attributes(params[:receipt])
      respond_to do |format|
        format.html { redirect_to(:action => 'receipts') }
        format.js { render :js => "window.location = '#{url_for(:action => "receipts")}'" }
      end
    else
      respond_to do |format|
        format.html { render('edit_receipt') }
        format.js { render "receipt_response" }
      end
    end
  end

  def delete_receipt
    @receipt = Receipt.find(params[:id])
  end

  def destroy_receipt
    @receipt = Receipt.find(params[:id])
    if @receipt.destroy
      redirect_to(:action => "receipts")
    else
      render :delete_receipt
    end
  end

  def toggle_uninvoiced
    @receipt = params[:receipt_id].present? ? Receipt.find(params[:receipt_id]) : Receipt.new
    @receipt.uninvoiced = params[:receipt].presence && params[:receipt][:uninvoiced].presence
    respond_to do |format|
      format.js { render "accounting/uninvoiced_receipts/show_receipts_items" }
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
      redirect_to(params[:original_url].presence ||url_for(:action => 'invoices'))
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
      redirect_to(:action => 'invoices')
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
      redirect_to(:action => "invoices")
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
      redirect_to(:action => "purchase_orders")
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
    @bill.job_costed = true
  end

  def toggle_jobcosted
    @bill = params[:bill_id].present? ? Bill.find(params[:bill_id]) : Bill.new
    @bill.job_costed = params[:bill].present? && params[:bill][:job_costed].present?
    respond_to do |format|
      format.js { render "accounting/un_job_costed_bills/show_bill_items" }
    end
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
    if @bill.destroy
      redirect_to(:action => "bills")
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
      redirect_to(params[:original_url].presence ||url_for(:action => "payments"))
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
      redirect_to(:action => "payments")
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
    redirect_to(:action => "payments")
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

  def show_estimate_items
    @invoice = params[:invoice_id].present? ? Invoice.find(params[:invoice_id]) : Invoice.new
    if params[:invoice].present? && params[:invoice][:estimate_id].present?
      @estimate = Estimate.find(params[:invoice][:estimate_id])
      @invoice = @estimate.invoices.build if @invoice.new_record?
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
    klass = params[:type].to_s.constantize
    @type = params[:type].to_s.underscore
    @purchasable = params[:id].present? ? klass.find(params[:id]) : klass.new
    @project = params[@type.to_sym][:project_id].present? ? Project.find(params[@type.to_sym][:project_id]) : nil
    respond_to do |format|
      format.js {}
    end
  end

  def show_category_items
    klass =  params[:type].to_s.constantize
    @type = params[:type].to_s.underscore
    @purchasable = params[:id].present? ? klass.find(params[:id]) : klass.new
    project = params[:project_id].present? ? Project.find(params[:project_id]) : nil
    category = params[@type.to_sym][:category_id].present? ? Category.find(params[@type.to_sym][:category_id]) : nil
    if project && category
      @categories_template = CategoriesTemplate.where(:category_id => category.id, :template_id => project.estimates.first.template.id).first_or_initialize
    else
      @categories_template = nil
    end
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

  def show_account_details_payables
    @account = Account.raw(session[:builder_id]).find(params[:account_id])
    session[:account_id] = @account.id
    respond_to do |format|
      format.js
    end
  end

  def show_account_details_receivables
    @account = Account.raw(session[:builder_id]).find(params[:account_id])
    session[:account_id] = @account.id
    respond_to do |format|
      format.js
    end
  end

  private
  def create_purchasable(type)
    klass =  type.to_s.constantize
    @type = type.to_s.underscore
    @purchasable = klass.new(params[@type.to_sym])
    @purchasable.builder_id = session[:builder_id]
    # Checking for valid payment
    if @purchasable.instance_of? Bill
      if params[:bill][:create_payment] == "1"
        payment = Payment.new(params[:payment].merge(:builder_id => session[:builder_id],
                                                      :vendor_id => @purchasable.vendor_id))
        unless payment.valid?
          @bill = @purchasable
          @bill.errors[:base] << "Payment information invalid: <br/> #{payment.errors.full_messages.join("<br/>")}"
          respond_to do |format|
            format.html { render("new_bill") }
            format.js { render "purchasable_response" }
          end
          return
        end
      end
    end
    assign_categories_template
    if @purchasable.save
      # Create payment simultaneously for bills
      if @purchasable.instance_of?(Bill) && payment && payment.save
        payment.payments_bills.create(bill_id: @purchasable.id, amount: @purchasable.total_amount)
      end
      respond_to do |format|
        format.html { redirect_to(params[:original_url].presence ||url_for(:action => @type.pluralize)) }
        format.js { render :js => "window.location = '#{ params[:original_url].presence ||url_for(:action => @type.pluralize)}'" }
      end
    else
      @bill = @purchase_order = @purchasable
      handle_purchasable_errors
      respond_to do |format|
        format.html { render("new_#{@type}") }
        format.js { render "purchasable_response" }
      end
    end
  end

  def update_purchasable(type)
    klass = type.to_s.constantize
    @type = type.to_s.underscore
    @purchasable = klass.find(params[:id])
    assign_categories_template
    if @purchasable.update_attributes(params[@type.to_sym])
      respond_to do |format|
        format.html { redirect_to(params[:original_url].presence ||url_for(:action => @type.pluralize)) }
        format.js { render :js => "window.location = '#{ params[:original_url].presence ||url_for(:action => @type.pluralize)}'" }
      end
    else
      @bill = @purchase_order = @purchasable
      handle_purchasable_errors
      respond_to do |format|
        format.html { render("edit_#{@type}") }
        format.js { render "purchasable_response" }
      end
    end
  end

  def assign_categories_template
    category_template = CategoriesTemplate.new
    if params[@type.to_sym][:category_id].present? && params[@type.to_sym][:project_id].present?
      project = Project.find(params[@type.to_sym][:project_id])
      category_template = CategoriesTemplate.where(:category_id => params[@type.to_sym][:category_id], :template_id => project.estimates.first.template.id).first
      unless category_template
        category = Category.find params[@type.to_sym][:category_id]
        if category
          category_template = category.categories_templates.where(:template_id => project.estimates.first.template.id).first
        end
        unless category_template
          category_template = CategoriesTemplate.create(:category_id => category.id, :template_id => project.estimates.first.template.id, :purchased => true)
        end
      end
      # Destroy all old purchasable_items if category template changed
      if @purchasable.categories_template_id != category_template.id
        params[@type.to_sym]["#{@type.pluralize}_items_attributes"]||= []
        @purchasable.purchasable_items.each do |pi|
          params[@type.to_sym]["#{@type.pluralize}_items_attributes"] << {id: pi.id, _destroy: true}.with_indifferent_access
        end
      end
    end
    @purchasable.categories_template_id = category_template.id
  end

  def handle_purchasable_errors
    if @purchasable.purchasable_items.select { |pi| pi.errors.any? }.any?
      msg = "Entering this payment will cause you to overpay the bid for following items:"
      msg << "<br/><ul>"
      @purchasable.purchasable_items.map(&:errors).each do |ie|
        msg << "<li>#{ie.full_messages.join(".")}</li>" if ie.full_messages.present?
      end
      msg << "</ul>"
      msg << "You can remedy the issue in one of the following ways:"
      msg << "<ol>"
      msg << "<li>If a change order billed to the client is needed, create a change order with the client for the amount over the bid.</li>"
      msg << "<li>If a change order with the subcontractor is needed and will be expensed to the company, then create a new bill for the amount that is over the original bid amount.</li>"
      msg << "<li> If the bid was renegotiated from the original agreement, then change the bid amount.</li>"
      msg << "</ol>"
      @purchasable.errors[:base] << msg
    end
  end
end
