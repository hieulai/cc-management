class ProjectsController < ApplicationController
  include ItemsHelper
  before_filter :authenticate_user!
  
  def list_current_projects
    #Finds all projects for every Client that have a "Current Project" status
    @projects = @builder.projects.current_project.sort_by { |p| p.current_progress }
    @next_tasks = params[:next_tasks]
  end
  
  def list_past_projects
    #Finds all projects for every Client that have a "Current Project" status
    @projects = @builder.projects.past_project
  end
  
  def show_project
    #Passes in parent model of Client
    @project = @builder.projects.find(params[:id])
    @client = @project.client
  end
  
  def edit_project
    @project = @builder.projects.find(params[:id])
    @client = @project.client
  end
  
  def update_project
    #Find object using form parameters
    @project = @builder.projects.find(params[:id])
    @client = @project.client
    if @project.update_attributes(params[:project]) && @client.update_attributes(params[:client])
      redirect_to(:action => 'list_current_projects')
    else
      render('edit_project')
    end
  end
  
  def edit_tasklist
    @project = @builder.projects.find(params[:id])
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

  def complete_task
    tasks = Task.find(params[:task_ids].keys)
    tasks.each do |task|
      task.update_attributes(:completed => true)
    end
    @project = tasks.first.tasklist.project
    respond_to do |format|
      format.js
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
    @change_order = @project.change_orders.build
    @categories = @builder.categories.raw
    @items = @builder.items
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
      @categories = @builder.categories.raw
      @items = @builder.items
      flash.now[:alert] = "please enter the data correctly."
      render :action => :new_change_order
    end
  end

  def edit_change_order
    @change_order = ChangeOrder.find(params[:id])
    @project = @change_order.project
    @categories = @builder.categories.raw
    @items = @builder.items
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
                      msg = item.errors.full_messages.join(".")
                      if item.errors.has_key? :invoice
                        msg += invoice_list item
                      end
                      @change_order.errors[:base] << msg
                    end
                  else
                    @item = Item.create(item_attributes)
                    change_orders_category.items << @item
                  end
                else
                  item = Item.find(item_val[:id])

                  unless item.destroy
                    msg = item.errors.full_messages.join(".")
                    if item.errors.has_key? :invoice
                      msg += invoice_list item
                    end
                    @change_order.errors[:base] << msg
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
        @categories = @builder.categories.raw
        @items = @builder.items
        return render :edit_change_order
      else
        redirect_to(:action => 'change_orders', :id => @change_order.project_id)
      end
    else
      @project = @change_order.project
      @categories = @builder.categories.raw
      @items = @builder.items
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
end
