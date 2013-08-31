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
    @projects = Project.where("builder_id = ? AND status ='Current Project'", session[:builder_id])
    @project = params[:id].present? ? Project.find(params[:id]) : @projects.first
  end

  def new_purchase_order
    @project = Project.find(params[:id])
    @purchase_order = PurchaseOrder.new
  end

  def create_purchase_order
    @project = Project.find(params[:id])
    @purchase_order = PurchaseOrder.new(params[:purchase_order])
    @purchase_order.amount = params[:item]
    if @purchase_order.save
      @project.purchase_orders << @purchase_order
      redirect_to(:action => 'purchase_orders', :id => @project.id)
    else
      render('new_purchase_order')
    end
  end

  def edit_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
    @project = @purchase_order.project
  end

  def update_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
    @project = @purchase_order.project
    @purchase_order.amount = params[:item]
    if @purchase_order.update_attributes(params[:purchase_order])
      redirect_to(:action => 'purchase_orders', :id => @purchase_order.project_id)
    else
      render('edit_purchase_order')
    end
  end

  def delete_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
  end

  def destroy_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
    @id = @purchase_order.project_id
    @purchase_order.destroy
    redirect_to(:action => 'purchase_orders', :id => @id)
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

  def show_project_purchase_orders
    @project = Project.find(params[:project][:id])
    respond_to do |format|
      format.js {}
    end
  end

  def show_categories_template_items
    @categories_template = CategoriesTemplate.find(params[:purchase_order][:categories_template_id])
    respond_to do |format|
      format.js {}
    end
  end
end
