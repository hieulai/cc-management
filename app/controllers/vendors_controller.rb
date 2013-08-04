class VendorsController < ApplicationController
    before_filter :confirm_logged_in
  
    def list
      @query = params[:query]
      @vendors = Vendor.where("builder_id = ?", session[:builder_id]).search(@query)
    end
  
    def show
      @vendor = Vendor.find(params[:id])
    end
  
    def new
      @vendor = Vendor.new
    end
  
    def create
      #Instantiate a new object using form parameters
      @builder = Builder.find(session[:builder_id])
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
    
    def import_export
      @vendor = Vendor.new
    end
  
    def import
      if params[:vendor].nil?
        redirect_to action: 'import_export', notice: "No file to import."
      else
        begin
          errors = Vendor.import(params[:vendor][:data], @builder)
          msg = "Item imported."
          unless errors.empty?
            msg = errors.join(",")
          end
          redirect_to action: 'list', notice: msg
        rescue StandardError => e
          redirect_to action: 'import_export', notice: e
        end
      end
    end
  
  end

