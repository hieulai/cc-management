class LeadsController < ApplicationController

  def list_current
    #add condition to filter leads by lead_status
    @leads = Lead.where(:lead_status => "Current Lead").order("leads.project_name ASC")
  end
  
  def list_past
    #add condition to filter leads by lead_status
    @leads = Lead.where(:lead_status => "Lost Lead").order("leads.project_name ASC")
  end
  
  def show
    @lead = Lead.find(params[:id])
  end
  
  def new
    @lead = Lead.new
  end
  
  def create
    #Instantiate a new object using form parameters
    @lead = Lead.new(params[:lead])
    #save subject
    if @lead.save
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list_current')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end
  
  def edit
    @lead = Lead.find(params[:id])
  end
  
  def update
    #Find object using form parameters
    @lead = Lead.find(params[:id])
    #Update subject
    if @lead.update_attributes(params[:lead])
      #if save succeeds, redirect to list action
      flash[:notice] = "Lead Updated."
      redirect_to(:action => 'list_current')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end
  
  def convert
    @lead = Lead.find(params[:id])
  end
  
  def conversion
    #Find object using form parameters
    @lead = Lead.find(params[:id])
    #Update subject
    if @lead.update_attributes(params[:lead])
      if @lead.lead_status = "Current Project"
        @project = Project.new
        @project.project_status = @lead.lead_status
        @project.project_name = @lead.project_name
        @project.project_type = @lead.project_type
        @project.expected_revenue = @lead.expected_revenue
        @project.save
      end  
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list_current')
    else
      #if save fails, redisplay form to user can fix problems
      render('convert')
    end
  end
  
  def delete
    @lead = Lead.find(params[:id])
  end
  
  def destroy
    Lead.find(params[:id]).destroy
    flash[:notice] = "Lead Deleted."
    redirect_to(:action => 'list_current')
  end
  #setup index rendering
  #setup past project rendering
  #setup creation of new project
  #setup editing of project
  #setup converting a project
  #setup destroying project
  #setup project show
  #setup print fucntionality
  #setup import/export functionality

end
