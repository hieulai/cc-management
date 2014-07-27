class EstimatesController < ApplicationController

  before_filter :authenticate_user!
    
    def list_current
      #add condition to filter leads by lead_status
      @estimates = @builder.estimates.current
    end

    def list_past
      #add condition to filter leads by lead_status
      @estimates = @builder.estimates.past
    end

    def show
      @estimate = @builder.estimates.find(params[:id])
      respond_to do |format|
        format.html
        format.pdf do
          render :pdf => "Estimate-#{@estimate.project.name}",
                 :layout => 'pdf.html',
                 #:show_as_html => true,
          :footer => {:center => 'Page [page]'}
        end
      end
    end

    def show_email
      @estimate = @builder.estimates.find(params[:id])
    end

    def send_email
      @estimate = @builder.estimates.find(params[:id])
      Mailer.delay.send_estimate(params[:to], params[:subject], params[:body], @estimate)
      redirect_to :action => 'show_email', :id => @estimate.id, :notice => "Email was sent."
    end

    def new
      @estimate = @builder.estimates.new
    end

    def create
      @template = @builder.templates.find(params[:template][:id])
      @estimate = @builder.estimates.new(params[:estimate].merge(:builder_id => @builder.id))
      @estimate.template = @template.clone_with_associations
      if @estimate.save
        #Assigns all appropriate measurements to the Estimate
        @measurements = Measurement.all
        @measurements.each do |m|
          @estimate.measurements << m
        end
        #if save succeeds, redirect to list action
        redirect_to(:action => 'edit', :id => @estimate.id )
      else
        #if save fails, redisplay form to user can fix problems
        render('new')
      end
    end

    def edit
      @estimate = @builder.estimates.find(params[:id])
    end

  def update
    #Find object using form parameters
    @estimate = @builder.estimates.find(params[:id])
    if @estimate.update_attributes(params[:estimate])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list_current')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end

    def edit_measurements
      @estimate = @builder.estimates.find(params[:id])
      @measurements = @estimate.measurements
    end

    def update_measurements
      #Find object using form parameters
      @estimate = @builder.estimates.find(params[:id])
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
      @estimate = @builder.estimates.find(params[:id])
      @template = @estimate.template
      @items = Item.where(builder_id: session[:builder_id]).order(:name)
      @categories = Category.where(builder_id: session[:builder_id]).order(:name)
    end

    def update_templates
      #Find object using form parameters
      @estimate = @builder.estimates.find(params[:id])
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
      @estimate = @builder.estimates.find(params[:id])
    end

    def conversion
      #Find object using form parameters
      @estimate = @builder.estimates.find(params[:id])
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
      @estimate = @builder.estimates.find(params[:id])
    end

  def destroy
    @estimate = @builder.estimates.find(params[:id])
    if @estimate.destroy
      redirect_to(:action => 'list_current')
    else
      render :delete
    end
  end

  def switch_type
    @estimate = @builder.estimates.find(params[:id])
    @estimate.kind = params[:estimate][:kind]
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

  def search_category_by_name
    categories_templates = []
    raw_categories = []
    unless params[:estimate_id].blank?
      estimate = @builder.estimates.find(params[:estimate_id])
      categories_templates= estimate.template.categories_templates
      original_categories= estimate.template.categories_templates.map { |c| c.category }

      raw_categories = @builder.categories.raw.reject { |c| original_categories.map { |c| c[:name] }.include? c.name }
      categories_templates.select! { |ct| ct.category.name == params[:name] }
      raw_categories.select! { |c| c.name == params[:name] }
    end
    if categories_templates.size > 0
      render :json => {:categories_template => {:id => categories_templates[0].id,
                                                :category_id => categories_templates[0].category_id,
                                                :name => categories_templates[0].category.name}}.to_json
    elsif raw_categories.size > 0
      render :json => {:category => {:id => raw_categories[0].id,
                                     :name => raw_categories[0].name}}.to_json
    else
      render :json => {}.to_json
    end
  end
end
