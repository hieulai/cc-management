class ItemsController < ApplicationController
  def list
    #passes in all items that do not have a category set
    # @items = Item.where(category_id: nil)
    #passes in all items that have categories set
    # @categories = Category.all
    @items = Item.select([:id, :name, :description, :cost, :unit, :margin, :notes])

    respond_to do |format|
      format.html
      format.csv {send_data Item.to_csv(@items)}
      format.xls
    end
  end

  def list_for_accounting
    #passes in all items that do not have a category set
    @items = Item.where(category_id: nil)
    #passes in all items that have categories set
    @categories = Category.all
  end

  def new
    @item = Item.new
    @categories = Category.all
  end

  def create
    @category = Category.find(params[:category][:id]) unless params[:category][:id].blank?
    @item = Item.new(params[:item])

    if @item.save && @category
      @item.categories << @category
      redirect_to(action: 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end

  def edit
    @item = Item.find(params[:id])
    @categories = Category.all
    @category = @item.categories.first.id unless @item.categories.blank?
  end

  def update
    #Find object using form parameters
    @item = Item.find(params[:id])
    @category = Category.find(params[:category][:id]) unless params[:category][:id].blank?
    #Update subject
    if @item.update_attributes(params[:item]) && @category
      @category.items << @item
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      @categories = Category.all
      render('edit')
    end
  end

  def delete
    @item = Item.find(params[:id])
  end

  def destroy
    Item.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end

  def transfer_data
    @item = Item.new
  end

  def import_export
    @item = Item.new
  end

  def import
    Item.import(params[:item])

    redirect_to :back, notice: "Item imported."
  end

end
