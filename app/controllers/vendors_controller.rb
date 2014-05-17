class VendorsController < ApplicationController
    before_filter :authenticate_user!
  
    def show
      @vendor = Vendor.find(params[:id])
    end
  
    def new
      @vendor = Vendor.new
    end
  
    def create
      #Instantiate a new object using form parameters
      @builder = Base::Builder.find(session[:builder_id])
      @vendor = Vendor.new(params[:vendor])
      #save subject
      if @vendor.save
        @builder.vendors << @vendor
        #if save succeeds, redirect to list action
        redirect_to(:action => 'list')
      else
        #if save fails, redisplay form to user can fix problems
        render('new')
      end
    end
  
    def edit
      @vendor = Vendor.find(params[:id])
    end
  
    def update
      #Find object using form parameters
      @vendor = Vendor.find(params[:id])
      #Update subject
      if @vendor.update_attributes(params[:vendor])
        #if save succeeds, redirect to list action
        redirect_to(:action => 'list')
      else
        #if save fails, redisplay form to user can fix problems
        render('edit')
      end
    end
  
    def delete
      @vendor = Vendor.find(params[:id])
    end

    def destroy
      Vendor.find(params[:id]).destroy
      redirect_to(:action => 'list')
    end
  
  end

