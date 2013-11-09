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

  def show_change_order
    @change_order = ChangeOrder.find(params[:id])
    respond_to do |format|
      format.pdf do
        render :pdf => "ChangeOrder-#{@change_order.name}",
               :layout => 'pdf.html',
               #:show_as_html => true, // for debugging html & css
               :footer => {:center => 'Page [page]'}
      end
    end
  end

  def show_change_order_email
    @change_order = ChangeOrder.find(params[:id])
  end

  def send_change_order_email
    @change_order = ChangeOrder.find(params[:id])
    Mailer.delay.send_co(params[:to], params[:subject], params[:body], @change_order)
    redirect_to :action => 'show_change_order_email', :id => @change_order.id, :notice => "Email was sent."
  end

  def new_change_order
    @project = Project.find(params[:id])
    @change_order = ChangeOrder.new
    @categories = Category.where("template_id IS NULL AND builder_id = ?", session[:builder_id])
    @items = Item.where("builder_id = ?", session[:builder_id])
  end

  def create_change_order
    @project = Project.find(params[:id])
    categories = params[:change_order][:change_orders_categories_attributes]
    params[:change_order].delete(:change_orders_categories_attributes)
    @change_order = ChangeOrder.new(params[:change_order].merge(:project_id => @project.id, :builder_id => session[:builder_id]))

    if @change_order.save
      unless categories.blank?
        categories.map do |key, val|
          unless val[:category_id].blank?
            change_orders_category = @change_order.change_orders_categories.create(category_id: val[:category_id])
            if val[:items_attributes] && val[:items_attributes].delete_if { |k, v| v[:id].blank? }
              items = val[:items_attributes].map { |k, v| v.slice!(:id, :_destroy) }
              unless items.empty?
                @items = Item.create(items)
                change_orders_category.items = @items
              end
            end
          end
        end
      end
      redirect_to action: 'change_orders', :id => @project.id
    else
      @categories = Category.where("template_id IS NULL AND builder_id = ?", session[:builder_id])
      @items = Item.where("builder_id = ?", session[:builder_id])
      flash.now[:alert] = "please enter the data correctly."
      render :action => :new_change_order
    end
  end

  def edit_change_order
    @change_order = ChangeOrder.find(params[:id])
    @project = @change_order.project
    @categories = Category.where("template_id IS NULL AND builder_id = ?", session[:builder_id])
    @items = Item.where("builder_id = ?", session[:builder_id])
  end

  def update_change_order
    @change_order = ChangeOrder.find(params[:id])
    categories = params[:change_order][:change_orders_categories_attributes]
    params[:change_order].delete(:change_orders_categories_attributes)
    if @change_order.update_attributes(params[:change_order])
      unless categories.blank?
        errors = []
        categories.map do |key, val|
          cat_temp_ids = @change_order.change_orders_categories.pluck(:id)
          if val["_destroy"].eql? "1"
            category_co =  @change_order.change_orders_categories.find(val[:id])
           unless category_co.destroy
             @change_order.errors[:base] << category_co.errors.full_messages.join(".")
           end
          elsif cat_temp_ids.include? val[:id].to_i
            change_orders_category = @change_order.change_orders_categories.find(val[:id])
            change_orders_category.update_attribute(:category_id, val[:category_id])
            if val[:items_attributes]
              val[:items_attributes].map do |item_key, item_val|
                unless (item_val["_destroy"].eql? "1")
                  next if item_val[:id].blank?
                  item = Item.find(item_val[:id])
                  next if item.nil?
                  item_attributes = item_val.except(:id, :_destroy)
                  if item.change_orders_category.present?
                    unless item.update_attributes(item_attributes)
                      @change_order.errors[:base] << item.errors.full_messages.join(".")
                    end
                  else
                    @item = Item.create(item_attributes)
                    change_orders_category.items << @item
                  end
                else
                  item = Item.find(item_val[:id])
                  unless item.destroy
                    @change_order.errors[:base] << item.errors.full_messages.join(".")
                  end
                end
              end

            end
          elsif val[:category_id].present?
            change_orders_category = @change_order.change_orders_categories.create(category_id: val[:category_id])
            if val[:items_attributes] && val[:items_attributes].delete_if { |k, v| v[:id].blank? }
              items = val[:items_attributes].map { |k, v| v.slice!(:id, :_destroy) }
              unless items.empty?
                @items = Item.create(items)
                change_orders_category.items = @items
              end
            end
          end
        end
      end

      if @change_order.errors.any?
        @project = @change_order.project
        @categories = Category.where("template_id IS NULL AND builder_id = ?", session[:builder_id])
        @items = Item.where("builder_id = ?", session[:builder_id])
        return render :edit_change_order
      else
        redirect_to(:action => 'change_orders', :id => @change_order.project_id)
      end
    else
      @project = @change_order.project
      @categories = Category.where("template_id IS NULL AND builder_id = ?", session[:builder_id])
      @items = Item.where("builder_id = ?", session[:builder_id])
      render :edit_change_order
    end
  end

  def delete_change_order
    @change_order = ChangeOrder.find(params[:id])
  end

  def destroy_change_order
    @change_order = ChangeOrder.find(params[:id])
    @id = @change_order.project_id
    respond_to do |format|
      format.html do
        if @change_order.destroy
          redirect_to(:action => 'change_orders', :id => @id)
        else
          render :delete_change_order
        end
      end
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
    @bid.amount = params[:item]
    @bid.project = @project
    #save subject
    if @bid.save
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
    @project = @bid.project
    @bid.amount = params[:item]
    #save subject
    begin
      if @bid.update_attributes(params[:bid])
        #if save succeeds, redirect to list action
        redirect_to(:action => 'bids', :id => @bid.project_id)
      else
        #if save fails, redisplay form to user can fix problems
        render('edit_bid')
      end
    rescue ActiveRecord::ReadOnlyRecord
      @bid.errors[:base] = "This record is Readonly"
      render('edit_bid')
    end
  end  
  
  def delete_bid
    @bid = Bid.find(params[:id])
  end
  
  def destroy_bid
    @bid = Bid.find(params[:id])
    @id = @bid.project_id
    begin
      @bid.destroy
      redirect_to(:action => 'bids', :id => @id)
    rescue ActiveRecord::ReadOnlyRecord
      @bid.errors[:base] = "This record is Readonly"
      render('delete_bid')
    end
  end

  def budget
    @project = Project.find(params[:id])
  end

  def show_item
    @item = Item.find(params[:item][:id])
    respond_to do |format|
      format.js {}
      format.json {
        render :json => @item.to_json
      }
    end
  end

  def show_categories_template_items
    @categories_template = CategoriesTemplate.find(params[:bid][:categories_template_id])
    @co_items = @categories_template.template.estimate.project.co_items(@categories_template.category)
    respond_to do |format|
      format.js {}
    end
  end

  def autocomplete_vendor_name
    @vendors = Vendor.where("builder_id = ?", session[:builder_id]).search_by_name(params[:term]).order(:company)
    render :json => @vendors.map { |v|
      label = v.company.present? ? "#{v.company} <br/> <span class=\"autocomplete-sublabel\">#{v.full_name}</span>" : v.full_name
      {:id => v.id, :label => label, :value => v.display_name}
    }.to_json
  end
    
end
