class AccountingController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    redirect_to(:action => 'payables')
  end

  def receivables
  end

  def deposits
    @query = params[:query]
    params[:sort_field] ||= "date"
    params[:sort_dir] ||= "desc"
    @deposits = Deposit.search {
      fulltext params[:query]
      with :builder_id, session[:builder_id]
      order_by params[:sort_field].to_sym, params[:sort_dir].to_sym if params[:sort_field] && params[:sort_dir]
      paginate :page => params[:page], :per_page => Kaminari.config.default_per_page
    }.results
  end

  def new_deposit
    @deposit = @builder.deposits.new
  end

  def create_deposit
    @deposit = @builder.deposits.new(params[:deposit])
    if @deposit.save
      redirect_to(params[:original_url].presence ||url_for(:action => 'deposits'))
    else
      render('new_deposit')
    end
  end

  def edit_deposit
    @deposit = @builder.deposits.find(params[:id])
  end

  def update_deposit
    @deposit = @builder.deposits.find(params[:id])
    # Destroy all old deposits_receipts_attributes if account changed
    if params[:deposit][:client_id].present? && params[:deposit][:client_id] != @deposit.client_id.to_s
      params[:deposit][:deposits_receipts_attributes] ||= []
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
    @deposit = @builder.deposits.find(params[:id])
  end

  def destroy_deposit
    @deposit = @builder.deposits.find(params[:id])
    @deposit.destroy
    redirect_to(:action => "deposits")
  end

  def receipts
    @query = params[:query]
    params[:sort_field] ||= "received_at"
    params[:sort_dir] ||= "desc"

    @receipts = Receipt.search {
      fulltext params[:query]
      with :builder_id, session[:builder_id]
      order_by params[:sort_field].to_sym, params[:sort_dir].to_sym if params[:sort_field] && params[:sort_dir]
      paginate :page => params[:page], :per_page => Kaminari.config.default_per_page
    }.results
  end

  def new_receipt
    @receipt = @builder.receipts.new
  end

  def create_receipt
    @receipt = @builder.receipts.new(params[:receipt])
    @create_deposit = params[:create_deposit]
    if @create_deposit == "1"
      deposit = @builder.deposits.new(params[:deposit])
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
      if deposit
        deposit.deposits_receipts.new(receipt_id: @receipt.id, amount: @receipt.amount)
        deposit.save
      end
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
    @receipt = @builder.receipts.find(params[:id])
  end

  def update_receipt
    @receipt = @builder.receipts.find(params[:id])
    # Destroy all old receipts_invoices_attributes if client changed
    if params[:receipt][:client_id].present? && params[:receipt][:client_id] != @receipt.client_id.to_s
      params[:receipt][:receipts_invoices_attributes] ||= []
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
    @receipt = @builder.receipts.find(params[:id])
  end

  def destroy_receipt
    @receipt = @builder.receipts.find(params[:id])
    if @receipt.destroy
      redirect_to(:action => "receipts")
    else
      render :delete_receipt
    end
  end

  def invoices
    @query = params[:query]
    params[:sort_field] ||= "invoice_date"
    params[:sort_dir] ||= "desc"
    @invoices = Invoice.search {
      fulltext params[:query]
      with :builder_id, session[:builder_id]
      order_by params[:sort_field].to_sym, params[:sort_dir].to_sym if params[:sort_field] && params[:sort_dir]
      paginate :page => params[:page], :per_page => Kaminari.config.default_per_page
    }.results
  end

  def invoice
    @invoice = @builder.invoices.find(params[:id])
    respond_to do |format|
      format.pdf do
        render :pdf => "Invoice-#{@invoice.id}",
               :layout => 'pdf.html',
               :show_as_html => params[:debug].present?,
               :footer => {:center => 'Page [page]'}
      end
    end
  end

  def invoice_email
    @invoice = @builder.invoices.find(params[:id])
  end

  def send_invoice_email
    @invoice = @builder.invoices.find(params[:id])
    Mailer.delay.send_invoice(params[:to], params[:subject], params[:body], @invoice)
    redirect_to :action => 'invoice_email', :id => @invoice.id, :notice => "Email was sent."
  end

 def new_invoice
   @invoice = @builder.invoices.new
 end

  def create_invoice
    @invoice = @builder.invoices.new(params[:invoice])
    if @invoice.save
      redirect_to(params[:original_url].presence ||url_for(:action => 'invoices'))
    else
      render('new_invoice')
    end
  end

  def edit_invoice
    @invoice = @builder.invoices.find(params[:id])
  end

  def update_invoice
    @invoice = @builder.invoices.find(params[:id])
    # Destroy all old invoices_items_attributes if estimate changed
    if params[:invoice][:estimate_id].present? && params[:invoice][:estimate_id] != @invoice.estimate_id.to_s
      if @invoice.estimate.cost_plus_bid?
        params[:invoice][:invoices_bills_categories_templates_attributes] ||= []
        @invoice.invoices_bills_categories_templates.each do |ii|
          params[:invoice][:invoices_bills_categories_templates_attributes] << {id: ii.id, _destroy: true}.with_indifferent_access
        end
      else
        params[:invoice][:invoices_items_attributes] ||= []
        @invoice.invoices_items.each do |ii|
          params[:invoice][:invoices_items_attributes] << {id: ii.id, _destroy: true}.with_indifferent_access
        end
      end
    end
    if @invoice.update_attributes(params[:invoice])
      redirect_to(:action => 'invoices')
    else
      render('edit_invoice')
    end
  end

  def delete_invoice
    @invoice = @builder.invoices.find(params[:id])
  end

  def destroy_invoice
    @invoice = @builder.invoices.find(params[:id])
    if @invoice.destroy
      redirect_to(:action => "invoices")
    else
      render :delete_invoice
    end
  end

  def purchase_orders
    @query = params[:query]
    @purchase_orders = PurchaseOrder.search {
      fulltext params[:query]
      with :builder_id, session[:builder_id]
      order_by params[:sort_field].to_sym, params[:sort_dir].to_sym if params[:sort_field] && params[:sort_dir]
      paginate :page => params[:page], :per_page => Kaminari.config.default_per_page
    }.results
  end

  def new_purchase_order
    @purchase_order = @builder.purchase_orders.new
  end

  def create_purchase_order
    create_purchasable(PurchaseOrder.name)
  end

  def edit_purchase_order
    @purchase_order = @builder.purchase_orders.find(params[:id])
  end

  def update_purchase_order
    update_purchasable(PurchaseOrder.name)
  end

  def delete_purchase_order
    @purchase_order = @builder.purchase_orders.find(params[:id])
  end

  def destroy_purchase_order
    @purchase_order = @builder.purchase_orders.find(params[:id])
    if @purchase_order.destroy
      redirect_to(:action => "purchase_orders")
    else
      render :delete_purchase_order
    end
  end

  def add_item_to_purchasable
    @type = params[:type]
    @item = Item.find(params[:item_id]) if params[:item_id].present?
    @category = Category.find(params[:category_id]) if params[:category_id].present?
    respond_to do |format|
      format.js {}
    end
  end

  def bills
    @type = params[:type]
    @query = params[:query]
    params[:sort_field] ||= "billed_date"
    params[:sort_dir] ||= "desc"
    @bills = Bill.search {
      fulltext params[:query]
      with :builder_id, session[:builder_id]
      with :remaining_amount, 0 if params[:type] == "paid"
      any_of do
        without(:remaining_amount).less_than(0)
        with(:remaining_amount, nil)
      end if params[:type] == "unpaid"

      all_of do
        without :remaining_amount, 0
        with(:due_date).less_than(Date.today)
      end if params[:type] == "late"
      order_by params[:sort_field].to_sym, params[:sort_dir].to_sym if params[:sort_field] && params[:sort_dir]
      paginate :page => params[:page], :per_page => Kaminari.config.default_per_page
    }.results
  end

  def new_bill
    @bill = @builder.bills.new({job_costed: true})
  end

  def create_bill
    create_purchasable(Bill.name)
  end

  def edit_bill
    @bill = @builder.bills.find(params[:id])
  end

  def update_bill
    update_purchasable(Bill.name)
  end

  def delete_bill
    @bill = @builder.bills.find(params[:id])
  end

  def destroy_bill
    @bill = @builder.bills.find(params[:id])
    if @bill.destroy
      redirect_to(:action => "bills")
    else
      render :delete_bill
    end
  end

  def payments
    @query = params[:query]
    params[:sort_field] ||= "date"
    params[:sort_dir] ||= "desc"
    @payments = Payment.search {
      fulltext params[:query]
      with :builder_id, session[:builder_id]
      order_by params[:sort_field].to_sym, params[:sort_dir].to_sym if params[:sort_field] && params[:sort_dir]
      paginate :page => params[:page], :per_page => Kaminari.config.default_per_page
    }.results
  end

  def new_payment
    @payment =  @builder.payments.new
    @bills = []
  end

  def create_payment
    @payment = @builder.payments.new(params[:payment])
    if @payment.save
      respond_to do |format|
        format.html { redirect_to(params[:original_url].presence ||url_for(:action => "payments")) }
        format.js { render :js => "window.location = '#{ params[:original_url].presence ||url_for(:action => "payments")}'" }
      end
    else
      @bills = []
      respond_to do |format|
        format.html { render("new_payment") }
        format.js { render "payment_response" }
      end
    end
  end

  def edit_payment
    @payment = @builder.payments.find(params[:id])
    @bills = @payment.bills
    @bills += @payment.payer.bills.unpaid if @payment.payer
    @bills.uniq!
  end

  def update_payment
    @payment = @builder.payments.find(params[:id])
    # Destroy all old payments_bills_attributes if payer changed
    if (params[:payment][:payer_id].present? && params[:payment][:payer_id] != @payment.payer_id.to_s) ||
        (params[:payment][:payer_type].present? && params[:payment][:payer_type] != @payment.payer_type.to_s)
      params[:payment][:payments_bills_attributes] ||= []
      @payment.payments_bills.each do  |pb|
        params[:payment][:payments_bills_attributes] << {id: pb.id, _destroy: true}.with_indifferent_access
      end
    end
    if @payment.update_attributes(params[:payment])
      respond_to do |format|
        format.html { redirect_to(:action => "payments") }
        format.js { render :js => "window.location = '#{ url_for(:action => "payments")}'" }
      end
    else
      @bills = (@payment.bills + @payment.payer.bills.unpaid).uniq
      respond_to do |format|
        format.html { render("edit_payment") }
        format.js { render "payment_response" }
      end
    end
  end
  
  def delete_payment
    @payment = @builder.payments.find(params[:id])
  end
  
  def destroy_payment
    @payment = @builder.payments.find(params[:id])
    @payment.destroy
    redirect_to(:action => "payments")
  end

  def print_check
    @payment = Payment.find(params[:id])
    respond_to do |format|
      format.pdf do
        render :pdf => "Check-#{@payment.id}",
               :layout => false,
               :show_as_html => params[:debug].present?,
               :page_size => 'Letter',
               :margin => {:top                => 0,
                           :bottom             => 0,
                           :left               => 0,
                           :right              => 0
               }
      end
    end
  end

  def show_estimate_items
    @invoice = params[:invoice_id].present? ? @builder.invoices.find(params[:invoice_id]) : @builder.invoices.new
    @from_date = params[:from_date]
    @to_date = params[:to_date]
    if params[:invoice].present? && params[:invoice][:estimate_id].present?
      @estimate = Estimate.find(params[:invoice][:estimate_id])
      @invoice = @estimate.invoices.build if @invoice.new_record?
    end
    respond_to do |format|
      format.js {}
    end
  end

  def show_people_bills
    @bills = []
    @payment = params[:payment_id].present? ? @builder.payments.find(params[:payment_id]) : @builder.payments.new
    if params[:payment].present? && params[:payment][:payer_id].present? && params[:payment][:payer_type].present?
      @payer = params[:payment][:payer_type].constantize.find params[:payment][:payer_id]
      @bills = @payer.bills.unpaid
      @bills += @payment.bills if @payment.payer == @payer
    end
    respond_to do |format|
      format.js {}
    end
  end

  def show_receipt_invoices
    @receipt = params[:receipt_id].present? ? @builder.receipts.find(params[:receipt_id]) : @builder.receipts.new
    @receipt.client = params[:receipt][:client_id].present? ? Client.find(params[:receipt][:client_id]) : nil
    @receipt.estimate = params[:receipt][:estimate_id].present? ? @builder.estimates.find(params[:receipt][:estimate_id]) : nil
    @invoices = @receipt.to_bill_invoices
    respond_to do |format|
      format.js {}
    end
  end

  def show_estimate_categories_template
    klass = params[:type].to_s.constantize
    @type = params[:type].to_s.underscore
    @purchasable = params[:id].present? ? klass.find(params[:id]) : klass.new
    @estimate = params[@type.to_sym][:estimate_id].present? ? @builder.estimates.find(params[@type.to_sym][:estimate_id]) : nil
    @purchasable.estimate = @estimate
    respond_to do |format|
      format.js {}
    end
  end

  def show_categories_template
    klass =  params[:type].to_s.constantize
    @type = params[:type].to_s.underscore
    @purchasable = params[:id].present? ? klass.find(params[:id]) : klass.new
    estimate = @builder.estimates.find(params[:estimate_id])
    @purchasable.estimate = estimate
    category = params[:category_select].present? ? Category.find(params[:category_select]) : nil
    if estimate && category
      @categories_template = CategoriesTemplate.where(:category_id => category.id, :template_id => estimate.template.id).first_or_initialize
      @p_ct = @categories_template.send("#{@type.pluralize}_categories_templates".to_sym).where("#{@type}_id".to_sym => @purchasable.id).first_or_initialize
    else
      @categories_template = nil
      @p_ct = nil
    end
    respond_to do |format|
      format.js {}
    end
  end

  def show_account_details_payables
    @account = @builder.accounts.find(params[:account_id])
    session[:account_id] = @account.id
    respond_to do |format|
      format.js
    end
  end

  def show_account_details_receivables
    @account = @builder.accounts.find(params[:account_id])
    session[:account_id] = @account.id
    respond_to do |format|
      format.js
    end
  end

  def reports
    render 'accounting/reports/reports'
  end

  def profit_loss_report
    render 'accounting/reports/profit_loss_report'
  end

  def project_expense_report
    render 'accounting/reports/project_expense_report'
  end

  def export_profit_loss_report
    @project_id = params[:project_id]
    if params[:from_date].present? && params[:to_date].present?
      @from_date = Date.parse(params[:from_date])
      @to_date = Date.parse(params[:to_date])
      if @from_date > @to_date
        flash[:notice] = "From Date has to before To Date"
      end
    else
      flash[:notice] = "From Date and To Date are required"
    end
    respond_to do |format|
      format.js { render "accounting/reports/export_profit_loss_report" }
    end
  end

  def export_project_expense_report
    msgs = []
    @project_id = params[:project_id]
    if @project_id.blank?
       msgs << "Project is required"
    end
    if params[:from_date].present? && params[:to_date].present?
      @from_date = Date.parse(params[:from_date])
      @to_date = Date.parse(params[:to_date])
      if @from_date > @to_date
        msgs << "From Date has to before To Date"
      end
    else
      msgs << "From Date and To Date are required"
    end
    flash[:notice] = msgs.join("<br/>")
    respond_to do |format|
      format.js { render "accounting/reports/export_project_expense_report" }
    end
  end

  def print_profit_loss_report
    redirect_to controller: "reports", action: "pl_report", from_date: params[:from_date], to_date: params[:to_date], project_id: params[:project_id], format: "pdf"
  end

  def print_project_expense_report
    redirect_to controller: "reports", action: "project_expense_report", from_date: params[:from_date], to_date: params[:to_date], project_id: params[:project_id], format: "pdf"
  end

  def client_accounts
    params[:type] ||= "Active"
    @clients = Client.search {
      fulltext params[:term], {:fields => :display_name}
      with :builder_id, session[:builder_id]
      without(:balance, 0) if params[:type] == "Active"
      order_by :display_name
      paginate :page => params[:page], :per_page => Kaminari.config.default_per_page
    }.results
    respond_to do |format|
      format.html {}
      format.js do
        render 'accounting/accounts/clients'
      end
    end
  end

  def vendor_accounts
    params[:type] ||= "Active"
    @vendors = Vendor.search {
      fulltext params[:term], {:fields => :display_name}
      with :builder_id, session[:builder_id]
      without(:balance, 0) if params[:type] == "Active"
      order_by :display_name
      paginate :page => params[:page], :per_page => Kaminari.config.default_per_page
    }.results
    respond_to do |format|
      format.html {}
      format.js do
        render 'accounting/accounts/vendors'
      end
    end
  end

  def list_projects
    @object = params[:type].constantize.find(params["id"])
    respond_to do |format|
      format.js do
        render 'accounting/shared/list_projects'
      end
    end
  end

  def show_account
    @type = params[:type]
    @object = @builder.send(@type.underscore.pluralize.to_sym).find(params[:id])
    @project = @builder.projects.find(params[:project_id]) if params[:project_id]
    if params[:page]
      @balance = @object.balance({project_id: params[:project_id], offset: (params[:page].to_i - 1) * Kaminari.config.default_per_page}).to_f
    else
      @balance = @object.balance({project_id: params[:project_id]}).to_f
    end
    @transactions = @object.transactions({project_id: params[:project_id]})
    respond_to do |format|
      format.js do
        @transactions = @transactions.page params[:page]
        render 'accounting/accounts/show_account'
      end
      format.pdf do

        render :pdf => "#{@type}-#{params[:id]}-Ledgers",
               :template => 'accounting/accounts/pdf/show_account',
               :layout => 'pdf.html',
               :show_as_html => params[:debug].present?,
               :footer => {:center => 'Page [page]'}
      end
    end
  end

  def show_account_email
    @type = params[:type]
    @object = @builder.send(@type.underscore.pluralize.to_sym).find(params[:id])
    @project = @builder.projects.find(params[:project_id]) if params[:project_id]
    render 'accounting/accounts/show_account_email'
  end

  def send_account_email
    @type = params[:type]
    @object = @builder.send(@type.underscore.pluralize.to_sym).find(params[:id])
    @project = @builder.projects.find(params[:project_id]) if params[:project_id]
    Mailer.delay.send_account(params[:to], params[:subject], params[:body], @object, @project)
    redirect_to :action => 'show_account_email', :id => @object.id, :type => @type, :project_id => params[:project_id], :notice => "Email was sent."
  end

  def invoices_from_receipt(receipt)
    return [] unless receipt.client
    invoices = receipt.estimate.present? ? receipt.invoices.estimate(@receipt.estimate.id) : receipt.invoices.client(@receipt.client_id)
    invoices+= receipt.estimate.present? ? receipt.estimate.invoices.unbilled : receipt.client.invoices.unbilled
    invoices.sort_by! { |i| [i.invoice_date, i.reference] }.uniq!
    invoices
  end

  private
  def create_purchasable(type)
    klass =  type.to_s.constantize
    @type = type.to_s.underscore
    assign_categories_templates
    @purchasable = klass.new(params[@type.to_sym])
    @purchasable.builder_id = session[:builder_id]
    if @purchasable.instance_of? Bill
      if params[:bill][:create_payment] == "1"
        payment = Payment.new(params[:payment].merge(:builder_id => session[:builder_id],
                                                     :payer_id => @purchasable.payer_id,
                                                     :payer_type => @purchasable.payer_type))
        unless payment.valid?
          @bill = @purchasable
          @bill.errors[:base] << "Payment information invalid: <br/> #{payment.errors.full_messages.join("<br/>")}"
        end
      end
    end

    if @purchasable.save
      # Create payment simultaneously for bills
      if @purchasable.instance_of?(Bill) && payment
        payment.payments_bills.new(bill_id: @purchasable.id, amount: @purchasable.total_amount)
        payment.save
      end
      respond_to do |format|
        format.html { redirect_to(params[:original_url].presence ||url_for(:action => @type.pluralize)) }
        format.js { render :js => "window.location = '#{ params[:original_url].presence ||url_for(:action => @type.pluralize)}'" }
      end
    else
      @bill = @purchase_order = @purchasable
      handle_purchasable_bid_amount_errors
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
    assign_categories_templates

    # Destroy all old po_cts if project changed
    if params[@type.to_sym][:estimate_id].present? && params[@type.to_sym][:estimate_id] != @purchasable.estimate_id.to_s && @purchasable.estimate
      @purchasable.send("#{@type.pluralize}_categories_templates".to_sym).each do |p_ct|
        params[@type.to_sym]["#{@type.pluralize}_categories_templates_attributes".to_sym] << {id: p_ct.id, _destroy: true}.with_indifferent_access
      end
    end

    if @purchasable.update_attributes(params[@type.to_sym])
      respond_to do |format|
        format.html { redirect_to(params[:original_url].presence ||url_for(:action => @type.pluralize)) }
        format.js { render :js => "window.location = '#{ params[:original_url].presence ||url_for(:action => @type.pluralize)}'" }
      end
    else
      @bill = @purchase_order = @purchasable
      handle_purchasable_bid_amount_errors
      respond_to do |format|
        format.html { render("edit_#{@type}") }
        format.js { render "purchasable_response" }
      end
    end
  end

  def assign_categories_templates
    if params[@type.to_sym][:estimate_id].present? && params[@type.to_sym]["#{@type.pluralize}_categories_templates_attributes".to_sym].present?
      estimate = @builder.estimates.find(params[@type.to_sym][:estimate_id])
      params[@type.to_sym]["#{@type.pluralize}_categories_templates_attributes".to_sym].each do |p_ct|
        next if p_ct[:category_id].blank? && p_ct[:_destroy] == true.to_s
        category_id = p_ct[:category_id].presence || Category.create({name: p_ct[:category_name]}).id
        category_template = CategoriesTemplate.where(:category_id => category_id, :template_id => estimate.template.id).first
        unless category_template
          category = Category.find(category_id)
          if category
            category_template = category.categories_templates.where(:template_id => estimate.template.id).first
          end
          unless category_template
            category_template = CategoriesTemplate.create(:category_id => category.id, :template_id => estimate.template.id, :purchased => true)
          end
        end
        p_ct[:categories_template_id] = category_template.id
      end
    end
  end

  def handle_purchasable_bid_amount_errors
    pis = @purchasable.purchasable_items.select { |pi| pi.errors.messages[:bid_amount].present? }
    if pis.any?
      msg = "Entering this payment will cause you to overpay the bid for following items:"
      msg << "<br/><ul>"
      pis.each do |pi|
        msg << "<li>#{pi.errors.messages[:bid_amount].first}</li>"
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
