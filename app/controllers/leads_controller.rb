class LeadsController < ApplicationController

  before_filter :authenticate_user!
  
  def list_current_leads
    #Finds all projects for every Client that have a "Current Lead"" status
    #@clients = Client.where("builder_id = ?", session[:builder_id]).joins(:projects).where(:projects => {:status => "Current Lead"})
    @projects = Project.where("builder_id = ? AND status = ?", session[:builder_id], "Current Lead").order("lead_stage ASC")
  end
  
  def list_past_leads
    #Finds all projects for every Client that have a "Past Lead" status
    @projects = Project.where("builder_id = ? AND status = ?", session[:builder_id], "Past Lead")
  end
  
  def new_client
    #creates new project, but is originally known as a "Lead"
    @project = Project.new
    @client =  Client.new
  end
  
  def existing_client
    #creates new project, but is originally known as a "Lead"
    @project = Project.new
  end
  
  def create_from_new
    #creates new project, but is originally known as a "Lead"
    @builder = Base::Builder.find(session[:builder_id])
    @client = Client.create(params[:client])
    @project = Project.new(params[:project])
    @project.builder_id = session[:builder_id]
    #save subject
    if @project.save 
      @client.projects << @project
      #Attaches Client to Base::Builder
      @builder.clients << @client
      redirect_to(:action => 'list_current_leads')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end
  
  def create_from_existing
    #creates new project, but is originally known as a "Lead"
    @builder = Base::Builder.find(session[:builder_id])
    @client = Client.find(params[:client][:id])
    @project = Project.create(params[:project])
    @project.builder_id = session[:builder_id]
    @project.save
    #save subject
    if @client.projects << @project     
      redirect_to(:action => 'list_current_leads')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end
  
  def show
    #Passes in parent model of Client
    @project = Project.find(params[:id])
    @client = Client.find(@project.client_id)
  end
  
  def edit
    @project = Project.find(params[:id])
    @client = Client.find(@project.client_id)
  end
  
  def update
    #Find object using form parameters
    
    @project = Project.find(params[:id])
    @client = Client.find(@project.client_id)
    #Update subject
    if @client.update_attributes(params[:client]) & @project.update_attributes(params[:project])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list_current_leads')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end
  
  def convert
    @project = Project.find(params[:id])
  end
  
  def conversion_lead
    #Find object using form parameters
    @project = Project.find(params[:id])
    @client = Client.find(@project.client_id)
    @project.update_attributes(params[:project])
    if @project.status == 'Current Project'
        @project.save
        #Allows client to display in the People section if the project is won.
        @client.status = "Active"
        @client.save
    elsif @project.status == "Past Lead"
        @project.save
        #Prevents client from displaying in the People section if the project is not won yet.
        @client.status = "Lead"
        @client.save
    elsif @project.status == "Current Lead"
        @project.save
        #Prevents client from displaying in the People section if the project is not won yet.
        @client.status = "Lead"
        @client.save
    end
    redirect_to(:action => 'list_current_leads')
  end
  
  def delete
    @project = Project.find(params[:id])
  end
  
  def destroy
    @project = Project.find(params[:id])
    @client = Client.find(@project.client_id)
    @project.destroy
    if @client.projects.empty?
      @client.destroy
    end
    redirect_to(:action => 'list_current_leads')
  end

end
