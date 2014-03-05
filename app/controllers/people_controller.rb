class PeopleController < ApplicationController
    before_filter :authenticate_user!

    def all
      @query = params[:query]
      clients = @query.present? ? @builder.clients.active.search(@query).records : @builder.clients.active
      vendors = @query.present? ? @builder.vendors.search(@query).records : @builder.vendors
      contacts = @query.present? ? @builder.contacts.search(@query).records : @builder.contacts
      @people = Kaminari.paginate_array(clients + vendors + contacts).page(params[:page])
    end
    
    def list_vendors
      @query = params[:query]
      @vendors = @query.present? ?  @builder.vendors.search(@query).records : @builder.vendors
      respond_to do |format|
        format.html { @vendors = @vendors.page(params[:page]) }
        format.csv {send_data Vendor.to_csv(@vendors)}
        format.xls { send_data @vendors.to_xls(:headers => Vendor::HEADERS, :columns => [:vendor_type, :trade, :company, :primary_first_name, :primary_last_name, :primary_email,
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
      @contacts = @query.present? ?  @builder.contacts.search(@query).records : @builder.contacts
      @contacts = @contacts.page(params[:page])
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
          errors = Vendor.importData(params[:vendor][:data], @builder)
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

    def autocomplete_name
      @peoples = []
      @peoples << @builder.clients.active.search_by_name(params[:term]).all
      @peoples << @builder.vendors.search_by_name(params[:term]).all
      @peoples << @builder.contacts.search_by_name(params[:term]).all
      render :json => @peoples.flatten.map { |p| {:id => p.id,
                                                  :label => p.full_name,
                                                  :value => p.full_name,
                                                  :type => p.class.name} }.to_json
    end
  
  end

