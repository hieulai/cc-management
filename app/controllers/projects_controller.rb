class ProjectsController < ApplicationController
  
  before_filter :confirm_logged_in
  
  def list_current_leads
    #Finds all projects for every Client that have a "Current Lead"" status
    @clients = Client.joins(:projects).where(:projects => {:status => "Current Lead"})
  end
  
  def list_current_projects
    #Finds all projects for every Client that have a "Current Project" status
    @clients = Client.joins(:projects).where(:projects => {:status => "Current Project"})
  end
  
  def list_past_projects
    #Finds all projects for every Client that have a "Current Project" status
    @clients = Client.joins(:projects).where(:projects => {:status => "Past Project"})
  end
  
  def list_past_leads
    #Finds all projects for every Client that have a "Past Lead" status
    @clients = Client.joins(:projects).where(:projects => {:status => "Past Lead"})
  end
  
  def new
    #creates new project, but is originally known as a "lead"
    @project = Project.new
    @client =  Client.new
  end
  
  def create
    #Instantiate a new object using form parameters
    @client = Client.new(params[:client])
    #save subject
    if @client.save
      #if save succeeds, attach project to client
      @project = @client.projects.create(params[:project])
      redirect_to(:action => 'list_current_leads')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end
  
  def show_lead
    #Passes in parent model of Client
    @project = Project.find(params[:id])
    @client = Client.find(@project.client_id)
  end
  
  def edit_lead
    @project = Project.find(params[:id])
    @client = Client.find(@project.client_id)
  end
  
  def update_lead
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
  
  def edit_project
    @project = Project.find(params[:id])
  end
  
  def update_project
    #Find object using form parameters
    @project = Project.find(params[:id])
    #Update subject
    if @project.update_attributes(params[:project])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list_current')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end
  
  def convert_lead
    @project = Project.find(params[:id])
  end
  
  def conversion_lead
    #Find object using form parameters
    @project = Project.find(params[:id])
    #Update subject
    if @project.update_attributes(params[:project])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list_current_leads')
    else
      #if save fails, redisplay form to user can fix problems
      render('convert')
    end
  end
  
  def convert_project
    @project = Project.find(params[:id])
  end
  
  def conversion_project
    #Find object using form parameters
    @project = Project.find(params[:id])
    #Update subject
    if @project.update_attributes(params[:project])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list_current_projects')
    else
      #if save fails, redisplay form to user can fix problems
      render('convert')
    end
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
  
  def tasklist
    
  end

end
