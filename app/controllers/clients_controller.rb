class ClientsController < ApplicationController
  
  def list_current_leads
    #lists all projects that are still in the lead stage
    @clients = Client.all
  end
  
  def show
    @client = Client.find(params[:id])
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
      #if save succeeds, redirect to list action
      @project = @client.projects.create(params[:project])
      redirect_to(:action => 'list_current_leads')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end
  
  def edit
    @client = Client.find(params[:id])
    @project = Project.find(params[:id])
  end
  
  def update
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
  
end
