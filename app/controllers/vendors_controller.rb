class VendorsController < ApplicationController
    before_filter :authenticate_user!
    
    def all
      @query = params[:query]
      @clients = @builder.clients.active.search(@query)
      @vendors = @builder.vendors.search(@query)
    end
    
    def list
      @query = params[:query]
      @vendors = @builder.vendors.search(@query)
      respond_to do |format|
        format.html
        format.csv {send_data Vendor.to_csv(@vendors)}
        format.xls { send_data @vendors.to_xls(:headers => Vendor::HEADERS, :columns => [:vendor_type, :trade, :company, :primary_first_name, :primary_last_name, :primary_email,
          :primary_phone1,:primary_phone1_tag, :primary_phone2,:primary_phone2_tag,:secondary_first_name, :secondary_last_name, :secondary_email, :secondary_phone1, :secondary_phone1_tag, 
          :secondary_phone2, :secondary_phone2_tag, :website, :address, :city, :state, :zipcode, 
          :notes]), content_type: 'application/vnd.ms-excel', filename: 'vendors.xls' }
      end
    end
  
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

