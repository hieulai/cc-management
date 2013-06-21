class SuppliersController < ApplicationController
  def list
    @suppliers = Supplier.all
  end
  
  def show
    @supplier = Supplier.find(params[:id])
  end
  
  def new
    @supplier =  Supplier.new
  end
  
  def create
    #Instantiate a new object using form parameters
    @supplier = Supplier.new(params[:supplier])
    #save subject
    if @supplier.save
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
    @supplier.destroy
    redirect_to(:action => 'list')
  end
end
