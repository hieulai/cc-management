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
    @categories = Category.find(ids)
    params[:template].delete(:categories_attributes)
    @template = Template.new(params[:template])
    @template.categories.delete_all

    @categories.each do |category|
      @template.categories << category
    end

    if @template.save
      redirect_to action: 'list'
    else
      @categories = Category.where("template_id IS NULL")
      render 'new'
    end
  end

  def edit
    @categories = Category.all
    @t_categories = @template.categories.pluck(:id)
    @items = Item.all
  end

  def update
    ids = params[:template][:categories_attributes].map{|key, val| val[:id]}
    @categories = Category.find(ids)
    # @item = Item.find(params[:item][:id]) if params[:item]
    @template = Template.find(params[:id])
    @template.categories.delete_all
    @template.categories = @categories
    @template.name = params[:template][:name]

    if @template.save
      #if save succeeds, redirect to list action
      redirect_to(action: 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end

  def delete; end

  def destroy
    @template.destroy
    redirect_to(action: 'list')
  end

  private

  def find_template
    @template = Template.find(params[:id])
  end
end
