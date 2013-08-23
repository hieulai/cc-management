class PeopleController < ApplicationController
    before_filter :authenticate_user!
    
    def all
      @query = params[:query]
      @clients = Client.where("builder_id = ? AND status = ?", session[:builder_id], "Active").search(@query)
      @vendors = Vendor.where("builder_id = ?", session[:builder_id]).search(@query)
      @contacts = Contact.where("builder_id = ?", session[:builder_id]).search(@query)
    end
    
    def list_vendors
      @query = params[:query]
      @vendors = Vendor.where("builder_id = ?", session[:builder_id]).search(@query)
      respond_to do |format|
        format.html
        format.csv {send_data Vendor.to_csv(@vendors)}
        format.xls { send_data @vendors.to_xls(:headers => Vendor::HEADERS, :columns => [:vendor_type, :trade, :company, :primary_first_name, :primary_last_name, :primary_email,
          :primary_phone1,:primary_phone1_tag, :primary_phone2,:primary_phone2_tag,:secondary_first_name, :secondary_last_name, :secondary_email, :secondary_phone1, :secondary_phone1_tag, 
          :secondary_phone2, :secondary_phone2_tag, :website, :address, :city, :state, :zipcode, 
          :notes]), content_type: 'application/vnd.ms-excel', filename: 'vendors.xls' }
      end
    end
  
    def show_vendor
      @vendor = Vendor.find(params[:id])
    end
  
    def new_vendor
      @vendor = Vendor.new
    end
  
    def create_vendor
      #Instantiate a new object using form parameters
      @builder = Builder.find(session[:builder_id])
      @vendor = Vendor.new(params[:vendor])
      #save subject
      if @vendor.save
        @builder.vendors << @vendor
        #if save succeeds, redirect to list action
        redirect_to(:action => 'list_vendors')
      else
        #if save fails, redisplay form to user can fix problems
        render('new_vendor')
      end
    end
  
    def edit_vendor
      @vendor = Vendor.find(params[:id])
    end
  
    def update_vendor
      #Find object using form parameters
      @vendor = Vendor.find(params[:id])
      #Update subject
      if @vendor.update_attributes(params[:vendor])
        #if save succeeds, redirect to list action
        redirect_to(:action => 'list_vendors')
      else
        #if save fails, redisplay form to user can fix problems
        render('edit_vendor')
      end
    end
  
    def delete_vendor
      @vendor = Vendor.find(params[:id])
    end

    def destroy_vendor
      Vendor.find(params[:id]).destroy
      redirect_to(:action => 'list_vendors')
    end
    
    def list_contacts
      @query = params[:query]
      @contacts = Contact.where("builder_id = ?", session[:builder_id]).search(@query)
    end
  
    def show_contact
      @contact = Contact.find(params[:id])
    end
  
    def new_contact
      @contact = Contact.new
    end
  
    def create_contact
      #Instantiate a new object using form parameters
      @builder = Builder.find(session[:builder_id])
      @contact = Contact.new(params[:contact])
      #save subject
      if @contact.save
        @builder.contacts << @contact
        #if save succeeds, redirect to list action
        redirect_to(:action => 'list_contacts')
      else
        #if save fails, redisplay form to user can fix problems
        render('new_contact')
      end
    end
  
    def edit_contact
      @contact = Contact.find(params[:id])
    end
  
    def update_contact
      #Find object using form parameters
      @contact = Contact.find(params[:id])
      #Update subject
      if @contact.update_attributes(params[:contact])
        #if save succeeds, redirect to list action
        redirect_to(:action => 'list_contacts')
      else
        #if save fails, redisplay form to user can fix problems
        render('edit_contact')
      end
    end
  
    def delete_contact
      @contact = Contact.find(params[:id])
    end

    def destroy_contact
      Contact.find(params[:id]).destroy
      redirect_to(:action => 'list_contacts')
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
          redirect_to action: 'list_vendors', notice: msg
        rescue StandardError => e
          redirect_to action: 'import_export', notice: e
        end
      end
    end
  
  end

