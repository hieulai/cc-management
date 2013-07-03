class TemplatesController < ApplicationController
  
  before_filter :confirm_logged_in
  before_filter :find_template, only: [:edit, :update, :delete, :destroy]

  def list
    @templates = Template.all
  end

  def new
    @template = Template.new
    @template.categories.build
    # Category.all.each { |category| category.update_attribute(:template_id, nil) if category.template.nil? }
    @categories = Category.where("template_id IS NULL")
    @items = Item.all
  end

  def create
    categories = params[:template][:categories_templates_attributes]
    params[:template].delete(:categories_templates_attributes)
    @template = @builder.templates.new(params[:template])

    if @template.save!
      # @template.categories_templates.create(categories)
      unless categories.blank?
        categories.map do |key, val|
          categories_template = @template.categories_templates.create(category_id: val[:category_id])
          if val[:items_attributes]
            item_ids = val[:items_attributes].map{ | k, v | v[:id]}
            @items = Item.find(item_ids)
            categories_template.items = @items
          end
        end
      end

      redirect_to action: 'list'
    else
      @categories = Category.where("template_id IS NULL")
      @template.categories.build
      flash.now[:alert] = "please enter the data correctly."
      render action: :new
    end
  end

  def edit
    @categories, @items = Category.all, Item.all
    @t_categories = @template.categories.pluck(:id)
    @t_items = Item.all
  end

  def update
    categories = params[:template][:categories_templates_attributes]
    params[:template].delete(:categories_templates_attributes)
    @template = Template.find(params[:id])
    @template.name = params[:template][:name]

    if @template.update_attributes(params[:template])
      #if save succeeds, redirect to list action
      unless categories.blank?
        categories.map do |key, val|
          cat_temp_ids = @template.categories_templates.pluck(:id)
          act_ids = @template.categories_templates.pluck(:category_id)
          if val["_destroy"].eql? "1"
            categories_template = @template.categories_templates.find(val[:id]).delete
          elsif cat_temp_ids.include? val[:id].to_i
            categories_template = @template.categories_templates.find(val[:id])
            categories_template.update_attribute(:category_id, val[:category_id])
            if val[:items_attributes]
              categories_template.items.destroy_all
              val[:items_attributes].map do |item_key, item_val|
                unless item_val["_destroy"].eql? "1"
                  @item = Item.find(item_val[:id])
                  categories_template.items << @item
                end
              end
            end
          else
            categories_template = @template.categories_templates.create(category_id: val[:category_id])
            if val[:items_attributes]
              item_ids = val[:items_attributes].map{ | k, v | v[:id]}
              @items = Item.find(item_ids)
              categories_template.items = @items
            end
          end
        end
      end

      redirect_to action: 'list'
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end

  def delete
    # find template with ID is already call in find_template with before filter
  end

  def destroy
    @template.destroy
    redirect_to(action: 'list')
  end

  private

  def find_template
    @template = Template.find(params[:id])
  end
end
