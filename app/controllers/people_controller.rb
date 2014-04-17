class PeopleController < ApplicationController
    before_filter :authenticate_user!

    def all
      @query = params[:query]
      clients = Client.search {
        fulltext params[:query]
        with :builder_id, session[:builder_id]
        with :status, "Active"
        paginate :page => 1, :per_page => Client.count
      }.results
      vendors = Vendor.search {
        fulltext params[:query]
        with :builder_id, session[:builder_id]
        paginate :page => 1, :per_page => Vendor.count
      }.results
      contacts = Contact.search {
        fulltext params[:query]
        with :builder_id, session[:builder_id]
        paginate :page => 1, :per_page => Contact.count
      }.results
      @people = Kaminari.paginate_array(clients + vendors + contacts).page(params[:page])
    end
    
    def list_vendors
      respond_to do |format|
        format.html do
          @query = params[:query]
          @vendors = Vendor.search {
            fulltext params[:query]
            with :builder_id, session[:builder_id]
            paginate :page => params[:page], :per_page => Kaminari.config.default_per_page
          }.results
        end
        format.csv {send_data Vendor.to_csv(@builder.vendors)}
        format.xls { send_data @builder.vendors.to_xls(:headers => Vendor::HEADERS, :columns => [:vendor_type, :trade, :company, :primary_first_name, :primary_last_name, :primary_email,
          :primary_phone1,:primary_phone1_tag, :primary_phone2,:primary_phone2_tag,:secondary_first_name, :secondary_last_name, :secondary_email, :secondary_phone1, :secondary_phone1_tag, 
          :secondary_phone2, :secondary_phone2_tag, :website, :address, :city, :state, :zipcode, 
          :notes]), content_type: 'application/vnd.ms-excel', filename: 'vendors.xls' }
      end
    end
  
    def show_vendor
      @vendor = @builder.vendors.find(params[:id])
    end
  
    def new_vendor
      @vendor = @builder.vendors.new
    end
  
    def create_vendor
      @vendor = @builder.vendors.new(params[:vendor])
      if @vendor.save
        redirect_to(:action => 'list_vendors')
      else
        render('new_vendor')
      end
    end
  
    def edit_vendor
      @vendor = @builder.vendors.find(params[:id])
    end
  
    def update_vendor
      @vendor = @builder.vendors.find(params[:id])
      if @vendor.update_attributes(params[:vendor])
        redirect_to(:action => 'list_vendors')
      else
        render('edit_vendor')
      end
    end
  
    def delete_vendor
      @vendor = @builder.vendors.find(params[:id])
    end

    def destroy_vendor
      @builder.vendors.find(params[:id]).destroy
      redirect_to(:action => 'list_vendors')
    end
    
    def list_contacts
      @query = params[:query]
      @contacts = Contact.search {
        fulltext params[:query]
        with :builder_id, session[:builder_id]
      }.results
    end
  
    def show_contact
      @contact = @builder.contacts.find(params[:id])
    end
  
    def new_contact
      @contact = @builder.contacts.new
    end
  
    def create_contact
      @contact = @builder.contacts.new(params[:contact])
      if @contact.save
        redirect_to(:action => 'list_contacts')
      else
        render('new_contact')
      end
    end
  
    def edit_contact
      @contact = @builder.contacts.find(params[:id])
    end
  
    def update_contact
      @contact = @builder.contacts.find(params[:id])
      if @contact.update_attributes(params[:contact])
        redirect_to(:action => 'list_contacts')
      else
        render('edit_contact')
      end
    end
  
    def delete_contact
      @builder.contacts.find(params[:id])
    end

    def destroy_contact
      @builder.contacts.find(params[:id]).destroy
      redirect_to(:action => 'list_contacts')
    end
    
    def import_export
      @vendor = @builder.vendors.new
    end

    def import
      if params[:vendor].nil?
        redirect_to action: 'import_export', notice: "No file to import."
      else
        begin
          result = Vendor.import(params[:vendor][:data], @builder)
          msg = "Vendor imported."
          unless result[:errors].empty?
            msg = result[:errors].join(",")
          end
          redirect_to action: 'list_vendors', notice: msg
        rescue StandardError => e
          redirect_to action: 'import_export', notice: e
        end
      end
    end

    def autocomplete_name
      @people = []
      if params[:type].present?
        scope = @builder.try(params[:type].downcase.pluralize.to_sym)
        scope = scope.active if params[:type] == Client.name
        @people << scope.search_by_name(params[:term]).all
      else
        @people << @builder.clients.active.search_by_name(params[:term]).all
        @people << @builder.vendors.search_by_name(params[:term]).all
        @people << @builder.contacts.search_by_name(params[:term]).all
      end
      render :json => @people.flatten.map { |p|
        label = p.company.present? ? "#{p.company} <br/> <span class=\"autocomplete-sublabel\">#{p.full_name}</span>" : p.full_name
        {:id => p.id, :label => label, :value => p.display_name, :type => p.class.name}
      }.to_json
    end
  
  end

