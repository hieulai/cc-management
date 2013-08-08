class ProjectsController < ApplicationController
  
  before_filter :confirm_logged_in
  
  def list_current_projects
    #Finds all projects for every Client that have a "Current Project" status
    @projects = Project.where("builder_id = ? AND status = ?", session[:builder_id], "Current Project")
  end
  
  def list_past_projects
    #Finds all projects for every Client that have a "Current Project" status
    @projects = Project.where("builder_id = ? AND status = ?", session[:builder_id], "Past Project")
  end
  
  def show_project
    #Passes in parent model of Client
    @project = Project.find(params[:id])
    @client = Client.find(@project.client_id)
  end
  
  def edit_project
    @project = Project.find(params[:id])
    @client = Client.find(@project.client_id)
  end
  
  def update_project
    #Find object using form parameters
    @project = Project.find(params[:id])
    @client = Client.find(@project.client_id)
    #Update subject
    if @client.update_attributes(params[:client]) & @project.update_attributes(params[:project])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list_current_projects')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end
  
  def convert_project
    @project = Project.find(params[:id])
  end
  
  def conversion_project
    #Find object using form parameters
    @project = Project.find(params[:id])
    @client = Client.find(@project.client_id)
    @project.update_attributes(params[:project])
    if @project.status == 'Current Project'
        @project.save
        #Allows client to display in the People section if the project is won.
        @client.status = "Active"
        @client.save
    elsif @project.status == "Past Project"
        @project.save
        #Prevents client from displaying in the People section if the project is not won yet.
        @client.status = "Active"
        @client.save
    elsif @project.status == "Current Lead"
        @project.save
        #Prevents client from displaying in the People section if the project is not won yet.
        @client.status = "Lead"
        @client.save
    end
    redirect_to(:action => 'list_current_projects')
    
  end
  
  def edit_tasklist
    @project = Project.find(params[:id])
    @tasklist = @project.tasklist
  end
  
  def update_tasklist
    @tasklist = Tasklist.find(params[:id])
    if @tasklist.update_attributes(params[:tasklist])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list_current_projects')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit_tasklist')
    end
  end
  
  def customize_tasklist
    @tasklist = Tasklist.find(params[:id])
  end
  
  def process_customize
    @tasklist = Tasklist.find(params[:id])
    if @tasklist.update_attributes(params[:tasklist])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'edit_tasklist', id: @tasklist.project_id)
    else
      #if save fails, redisplay form to user can fix problems
      render('edit_tasklist')
    end
  end
  
  def tasklist
    @project = Project.find(params[:id])
    if @project.tasklist
      redirect_to :action => 'edit_tasklist', id: @project.id
    else
      redirect_to :action => 'select_tasklist', id: @project.id
    end
  end
  
  def select_tasklist
    @project = Project.find(params[:id])
  end

  def assign_tasklist
    @project = Project.find(params[:id])
    @original_list = Tasklist.find(params[:tasklist][:id])
    @project_list = Tasklist.new
    @original_list.tasks.each do |task|
      @new_task = Task.new
      @new_task.name = task.name
      @new_task.position = task.position
      @new_task.time_to_complete = task.time_to_complete
      @project_list.tasks << @new_task
    end
    
    if @project.tasklist = @project_list
      redirect_to :action => 'edit_tasklist', id: @project.id
    else
      render 'select_tasklist'
    end
  end
  
  def change_tasklist
    @tasklist = Tasklist.find(params[:id])
  end
  
  def destroy_tasklist
    @tasklist = Tasklist.find(params[:id])
    @project_id = @tasklist.project_id
    @tasklist.destroy
    redirect_to(:action => 'select_tasklist', id: @project_id)
  end
  
  def bids
    @project = Project.find(params[:id])
    @bids = @project.bids
  end
  
  def new_bid
    @project = Project.find(params[:id])
    @bid = Bid.new
  end
  
  def create_bid
    #Instantiate a new object using form parameters
    @project = Project.find(params[:id])
    @bid = Bid.new(params[:bid])
    @category = Category.find(params[:category][:id])
    @vendor = Vendor.find(params[:vendor][:id])
    @bid.category = @category
    @bid.vendor = @vendor
    #save subject
    if @bid.save
      @project.bids << @bid
      #if save succeeds, redirect to list action
      redirect_to(:action => 'bids', :id => @bid.project_id)
    else
      #if save fails, redisplay form to user can fix problems
      render('new_bid')
    end
  end
  
  def edit_bid
    @bid = Bid.find(params[:id])
    @category = @bid.category
    @vendor = @bid.vendor
  end
  
  def update_bid
    #Instantiate a new object using form parameters
    @bid = Bid.find(params[:id])
    @category = Category.find(params[:category][:id])
    @vendor = Vendor.find(params[:vendor][:id])
    @bid.category = @category
    @bid.vendor = @vendor
    #save subject
    if @bid.update_attributes(params[:bid])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'bids', :id => @bid.project_id)
    else
      #if save fails, redisplay form to user can fix problems
      render('new_bid')
    end
  end  
  
  def delete_bid
    @bid = Bid.find(params[:id])
  end
  
  def destroy_bid
    Bid.find(params[:id]).destroy
    redirect_to(:action => 'bids')
  end
    
end
