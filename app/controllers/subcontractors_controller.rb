class SubcontractorsController < ApplicationController

  before_filter :authenticate_user!
  
  def list
    @query = params[:query]
    @subcontractors = Subcontractor.where("builder_id = ?", session[:builder_id]).search(@query)
    respond_to do |format|
      format.html
      format.csv {send_data Subcontractor.to_csv(@subcontractors)}
      format.xls { send_data @subcontractors.to_xls(:headers => Subcontractor::HEADERS, :columns => [:trade, :company, :first_name, :last_name, :email,
        :primary_phone,:primary_phone_tag, :secondary_phone, :secondary_phone_tag, :website, :address, :city, :state, :zipcode, 
        :notes]), content_type: 'application/vnd.ms-excel', filename: 'subcontractors.xls' }
    end
  end
  
  def show
    @subcontractor = Subcontractor.find(params[:id])
  end
  
  def new
    @subcontractor =  Subcontractor.new
  end
  
  def create
    #Instantiate a new object using form parameters
    @builder = Builder.find(session[:builder_id])
    @subcontractor = Subcontractor.new(params[:subcontractor])
    #save subject
    if @subcontractor.save
      @builder.subcontractors << @subcontractor
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end
  
  def edit
    @subcontractor = Subcontractor.find(params[:id])
  end
  
  def update
    #Find object using form parameters
    @subcontractor = Subcontractor.find(params[:id])
    #Update subject
    if @subcontractor.update_attributes(params[:subcontractor])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end
  
  def delete
    @subcontractor = Subcontractor.find(params[:id])
  end

  def destroy
    Subcontractor.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end
  
  def import_export
    @subcontractor = Subcontractor.new
    @subcontractors = Subcontractor.where("builder_id = ?", session[:builder_id])
    respond_to do |format|
      format.html
      format.csv {render text: @subcontractors.to_csv}
    end
  end
  
  def import
    if params[:subcontractor].nil?
      redirect_to action: 'import_export', notice: "No file to import."
    else
      begin
        errors = Subcontractor.import(params[:subcontractor][:data], @builder)
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
