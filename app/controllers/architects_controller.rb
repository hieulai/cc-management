class ArchitectsController < ApplicationController
  before_filter :authenticate_user!
  
  def list
    @query = params[:query]
    @architects = Architect.where("builder_id = ?", session[:builder_id]).search(@query)
    respond_to do |format|
      format.html
      format.csv {send_data Architect.to_csv(@architects)}
      format.xls { send_data @architects.to_xls(:headers => Architect::HEADERS, :columns => [:company, :first_name, :last_name, :email,
        :primary_phone,:primary_phone_tag, :secondary_phone, :secondary_phone_tag, :website, :address, :city, :state, :zipcode, 
        :notes]), content_type: 'application/vnd.ms-excel', filename: 'architects.xls' }
    end
  end
  
  def show
    @architect = Architect.find(params[:id])
  end
  
  def new
    @architect =  Architect.new
  end
  
  def create
    #Instantiate a new object using form parameters
    @builder = Builder.find(session[:builder_id])
    @architect = Architect.new(params[:architect])
    #save subject
    if @architect.save
      @builder.architects << @architect
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end
  
  def edit
    @architect = Architect.find(params[:id])
  end
  
  def update
    #Find object using form parameters
    @architect = Architect.find(params[:id])
    #Update subject
    if @architect.update_attributes(params[:architect])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end
  
  def delete
    @architect= Architect.find(params[:id])
  end

  def destroy
    Architect.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end
  
  def import_export
  
  end
  
end
