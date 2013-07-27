class EstimatesController < ApplicationController
  
    before_filter :confirm_logged_in
    
    def list_current
      #add condition to filter leads by lead_status
      @estimates = Estimate.where("builder_id = ? AND status = ?", session[:builder_id], "Current Estimate")
    end

    def list_past
      #add condition to filter leads by lead_status
      @estimates = Estimate.where("builder_id = ? AND status = ?", session[:builder_id], "Past Estimate")
    end

    def show
      @estimate = Estimate.find(params[:id])
    end

    def new
      @estimate = Estimate.new
    end

    def create
      @builder = Builder.find(session[:builder_id])
      #Reads in the project ID selected by the User
      @project = Project.find(params[:project][:id])
      #Reads in the project ID selected by the User
      @template = Template.find(params[:template][:id])
      #Assigns the estimate to the correct Project
      @estimate = @project.estimates.new(params[:estimate])
      @estimate.template = @template.clone_with_associations
      #saves creation of Estimate
      if @estimate.save
        @builder.estimates << @estimate
        
        #Assigns all appropriate measurements to the Estimate
        @measurements = Measurement.all
        @measurements.each do |m|
          @estimate.measurements << m
        end
        #if save succeeds, redirect to list action
        redirect_to(:action => 'list_current')
      else
        #if save fails, redisplay form to user can fix problems
        render('new')
      end
    end

    def edit
      @estimate = Estimate.find(params[:id])
      @template = @estimate.template
      @items = Item.where(builder_id: session[:builder_id]).order(:name)
      @categories = Category.where(builder_id: session[:builder_id]).order(:name)
    end

    def update
      #Find object using form parameters
      @estimate = Estimate.find(params[:id])
      @template = Template.find(params[:template][:id])
      @estimate.template = @template
      #Update subject
      if @estimate.update_attributes(params[:estimate])
        #if save succeeds, redirect to list action
        redirect_to(:action => 'list_current')
      else
        #if save fails, redisplay form to user can fix problems
        render('edit')
      end
    end

    def edit_measurements
      @estimate = Estimate.find(params[:id])
      @measurements = @estimate.measurements
    end

    def update_measurements
      #Find object using form parameters
      @estimate = Estimate.find(params[:id])
      #Update subject
      if @estimate.update_attributes(params[:estimate])
        #if save succeeds, redirect to list action
        redirect_to(:action => 'list_current')
      else
        #if save fails, redisplay form to user can fix problems
        render('edit')
      end
    end

    def edit_templates
      @estimate = Estimate.find(params[:id])
      @items = Item.where(builder_id: session[:builder_id]).order(:name)
      @categories = Category.where(builder_id: session[:builder_id]).order(:name)
    end

    def update_templates
      #Find object using form parameters
      @estimate = Estimate.find(params[:id])
      #Update subject
      if @estimate.update_attributes(params[:estimate])
        #if save succeeds, redirect to list action
        redirect_to(:action => 'list_current')
      else
        #if save fails, redisplay form to user can fix problems
        render('edit')
      end
    end

    def convert
      @estimate = Estimate.find(params[:id])
    end

    def conversion
      #Find object using form parameters
      @estimate = Estimate.find(params[:id])
      #Update subject
      if @estimate.update_attributes(params[:estimate])
        #if save succeeds, redirect to list action
        redirect_to(:action => 'list_current')
      else
        #if save fails, redisplay form to user can fix problems
        render('convert')
      end
    end

    def delete
      @estimate = Estimate.find(params[:id])
    end

    def destroy
      @estimate = Estimate.find(params[:id])
      unless @estimate.template.nil?
        @estimate.template.destroy_with_associations
      end
      @estimate.destroy
      redirect_to(:action => 'list_current')
    end

    def show_template
      @template = Template.find(params[:template][:id])
      @items = Item.where(builder_id: session[:builder_id]).order(:name)
      @categories = Category.where(builder_id: session[:builder_id]).order(:name)
      respond_to do |format|
        format.js {}
      end
    end

    def add_item
      @category_template = CategoriesTemplate.find(params[:category_template_id])
      @item = Item.find(params[:item][:id]).dup
      @item.builder_id = nil
      @category_template.items << @item
      respond_to do |format|
        format.js {}
      end
    end

    def add_category
      @template = Template.find(params[:template_id])
      @category = Category.find(params[:category][:id]).dup
      @category.builder_id = nil
      @category.save
      @category_template = @template.categories_templates.create(category_id: @category.id)
      @items = Item.where(builder_id: session[:builder_id]).order(:name)
      respond_to do |format|
        format.js {}
      end
    end

end
