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

    @categories.each do |category|
      @template.categories << category
    end

    if @template.save
      redirect_to action: 'list'
    else
      render 'new'
    end
  end

  def edit
    @categories = Category.where("template_id IS NULL OR template_id = ?", @template.id)
    @items = Item.all
    # @template = Template.find(params[:id])
  end

  def update
    ids = params[:template][:categories_attributes].map{|key, val| val[:id]}
    @categories = Category.find(ids)
    @template = Template.find(params[:id])
    @item = Item.find(params[:item][:id]) if params[:item]
    @template.categories.delete_all

    @categories.each do |category|
      @template.categories << category
    end
    #Find object using form parameters

    #Update subject
    if @template.update_attributes(params[:template])
        @category.items << @item if @item
      #if save succeeds, redirect to list action
      redirect_to(action: 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end

  def delete
    # @template = Template.find(params[:id])
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
