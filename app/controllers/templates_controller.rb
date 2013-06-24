class TemplatesController < ApplicationController
  before_filter :find_template, only: [:edit, :update, :delete, :destroy]

  def list
    @templates = Template.all
  end

  def new
    @template = Template.new
    @template.categories.build
    Category.all.each { |category| category.update_attribute(:template_id, nil) if category.template.nil? }
    @categories = Category.where("template_id IS NULL")
  end

  def create
    ids = params[:template][:categories_attributes].map{|key, val| val[:id]}
    params[:template].delete(:categories_attributes)
    @template = Template.new(params[:template])

    unless ids[0].blank?
      @categories = Category.find(ids)
      @template.categories = @categories
    end

    if @template.save! && @categories
      redirect_to action: 'list'
    else
      @categories = Category.where("template_id IS NULL")
      @template.categories.build
      flash.now[:alert] = "please enter the data correctly."
      render action: :new
    end
  end

  def edit
    @categories = Category.all
    @t_categories = @template.categories.pluck(:id)
    @items = Item.all
  end

  def update
    ids = params[:template][:categories_attributes].map{|key, val| val[:id]}
    # @item = Item.find(params[:item][:id]) if params[:item]
    @template = Template.find(params[:id])
    @template.name = params[:template][:name]

    unless ids[0].blank?
      @categories = Category.find(ids)
      @template.categories = @categories
    end
    #Find object using form parameters

    if @template.update_attributes(params[:template])
      #if save succeeds, redirect to list action
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
