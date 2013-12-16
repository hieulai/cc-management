class EstimatesController < ApplicationController

  before_filter :authenticate_user!
    
    def list_current
      #add condition to filter leads by lead_status
      @estimates = Estimate.current(session[:builder_id])
    end

    def list_past
      #add condition to filter leads by lead_status
      @estimates = Estimate.past(session[:builder_id])
    end

    def show
      @estimate = Estimate.find(params[:id])
      respond_to do |format|
        format.html
        format.pdf do
          render :pdf => "Estimate-#{@estimate.project.name}",
                 :layout => 'pdf.html',
                 #:show_as_html => true, // for debugging html & css
          :footer => {:center => 'Page [page]'}
        end
      end
    end

    def show_email
      @estimate = Estimate.find(params[:id])
    end

    def send_email
      @estimate = Estimate.find(params[:id])
      Mailer.delay.send_estimate(params[:to], params[:subject], params[:body], @estimate)
      redirect_to :action => 'show_email', :id => @estimate.id, :notice => "Email was sent."
    end

    def new
      @estimate = Estimate.new
    end

    def create
      @builder = Base::Builder.find(session[:builder_id])
      @template = Template.find(params[:template][:id])
      @estimate = Estimate.new(params[:estimate].merge(:builder_id => @builder.id))
      @estimate.template = @template.clone_with_associations
      if @estimate.save
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
    end

    def update
      #Find object using form parameters
      @estimate = Estimate.find(params[:id])
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
      @template = @estimate.template
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
    if @estimate.destroy
      redirect_to(:action => 'list_current')
    else
      render :delete
    end
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
