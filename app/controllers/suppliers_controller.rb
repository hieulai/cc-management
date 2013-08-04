class SuppliersController < ApplicationController
  
  before_filter :confirm_logged_in
  
  def list
    @query = params[:query]
    @suppliers = Supplier.where("builder_id = ?", session[:builder_id]).search(@query)
    respond_to do |format|
      format.html
      format.csv {send_data Supplier.to_csv(@suppliers)}
      format.xls { send_data @suppliers.to_xls(:headers => Supplier::HEADERS, :columns => [:company, :primary_first_name, :primary_last_name, :primary_email,
        :primary_phone,:primary_phone_tag, :secondary_first_name, :secondary_last_name, :secondary_email, :secondary_phone, :secondary_phone_tag, :website, :address, :city, :state, :zipcode, 
        :notes]), content_type: 'application/vnd.ms-excel', filename: 'suppliers.xls' }
    end
  end
  
  def show
    @supplier = Supplier.find(params[:id])
  end
  
  def new
    @supplier =  Supplier.new
  end
  
  def create
    #Instantiate a new object using form parameters
    @builder = Builder.find(session[:builder_id])
    @supplier = Supplier.new(params[:supplier])
    #save subject
    if @supplier.save
      @builder.suppliers << @supplier
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end
  
  def edit
    @supplier = Supplier.find(params[:id])
  end
  
  def update
    #Find object using form parameters
    @supplier = Supplier.find(params[:id])
    #Update subject
    if @supplier.update_attributes(params[:supplier])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end
  
  def delete
    @supplier = Supplier.find(params[:id])
  end

  def destroy
    Supplier.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end
end
