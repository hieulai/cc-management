class ProjectsController < ApplicationController

  before_filter :authenticate_user!
  
  def list_current_projects
    #Finds all projects for every Client that have a "Current Project" status
    @projects = Project.where("builder_id = ? AND status = ?", session[:builder_id], "Current Project").sort_by {|p| p.current_progress}
    @next_tasks = params[:next_tasks]
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
    @project = Project.find(@tasklist.project_id)
    if @tasklist.update_attributes(params[:tasklist])
      #if save succeeds, redirect to list action
      redirect_to :action => 'list_current_projects'
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

  def specifications
    @project = Project.find(params[:id])
    @specifications = @project.specifications
  end
  
  def new_specification
    @project = Project.find(params[:id])
    @specification = Specification.new
  end
  
  def create_specification
    #Instantiate a new object using form parameters
    @project = Project.find(params[:id])
    @specification = Specification.new(params[:specification])
    @category = Category.find(params[:category][:id])
    @specification.category = @category
    #save subject
    if @specification.save 
      
      @project.specifications << @specification
      @project.save
      #@specification.save
      #if save succeeds, redirect to list action
      redirect_to(:action => 'specifications', :id => @specification.project_id)
    else
      #if save fails, redisplay form to user can fix problems
      render('new_specification')
    end
  end
  
  def edit_specification
    @specification = Specification.find(params[:id])
    @category = @specification.category
  end
  
  def update_specification
    #Instantiate a new object using form parameters
    @specification = Specification.find(params[:id])
    @category = Category.find(params[:category][:id])
    @specification.category = @category
    #save subject
    if @specification.update_attributes(params[:specification])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'specifications', :id => @specification.project_id)
    else
      #if save fails, redisplay form to user can fix problems
      render('new_specification')
    end
  end  
  
  def delete_specification
    @specification = Specification.find(params[:id])
  end
  
  def destroy_specification
    @specification = Specification.find(params[:id])
    @id = @specification.project_id
    @specification.destroy
    redirect_to(:action => 'specifications', :id => @id)
    
  end
  
  
  def change_orders
    @project = Project.find(params[:id])
    @change_orders = @project.change_orders
  end

  def new_change_order
    @project = Project.find(params[:id])
    @change_order = ChangeOrder.new
  end

  def create_change_order
    @project = Project.find(params[:id])
    @change_order = ChangeOrder.new(params[:change_order])
    @change_order.project_id = @project.id
    if @change_order.save
      redirect_to :action => 'change_orders', :id => @project.id
    else
      render :new_change_order
    end
  end

  def edit_change_order
    @change_order = ChangeOrder.find(params[:id])
    @project = @change_order.project
  end

  def update_change_order
    @change_order = ChangeOrder.find(params[:id])
    if @change_order.update_attributes(params[:change_order])
      redirect_to(:action => 'change_orders', :id => @change_order.project_id)
    else
      render :edit_change_order
    end
  end

  def delete_change_order
    @change_order = ChangeOrder.find(params[:id])
  end

  def destroy_change_order
    @change_order = ChangeOrder.find(params[:id])
    @id = @change_order.project_id
    @change_order.destroy
    redirect_to(:action => 'change_orders', :id => @id)
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
    @bid.amount = params[:item]
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
    @project = @bid.project
  end
  
  def update_bid
    #Instantiate a new object using form parameters
    @bid = Bid.find(params[:id])
    @bid.amount = params[:item]
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
    @bid = Bid.find(params[:id])
    @id = @bid.project_id
    @bid.destroy
    redirect_to(:action => 'bids', :id => @id)
  end

  def budget
    @project = Project.find(params[:id])
  end

  def show_item
    @item = Item.find(params[:item][:id])
    respond_to do |format|
      format.js {}
    end
  end

  def show_categories_template_items
    @categories_template = CategoriesTemplate.find(params[:bid][:categories_template_id])
    respond_to do |format|
      format.js {}
    end
  end

  def autocomplete_vendor_name
    @vendors = Vendor.where("builder_id = ?", session[:builder_id]).search_by_name(params[:term]).order(:primary_first_name)
    render :json => @vendors.map { |v|
      label = v.trade.present? ? "#{v.trade} <br/> <span class=\"autocomplete-sublabel\">#{v.full_name}</span>" : v.full_name
      {:id => v.id, :label => label, :value => v.display_name}
    }.to_json
  end
    
end
