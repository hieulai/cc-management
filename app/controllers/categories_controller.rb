class CategoriesController < ApplicationController
  before_filter :authenticate_user!
  
  def list
    @categories = @builder.categories
  end

  def new
    @category = @builder.categories.new
  end

  def create
    @category = @builder.categories.new(params[:category])
    if @category.save
      @builder.categories << @category
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end

  def edit
    @category= @builder.categories.find(params[:id])
  end

  def update
    @category= @builder.categories.find(params[:id])
    #Update subject
    respond_to do |format|
      if @category.update_attributes(params[:category])
        format.html {redirect_to(:action => 'list')}
        format.json { render json: @category }
      else
        format.html {render('edit')}
        format.json { render json: resource.errors}
      end
    end
  end

  def delete
    @category= @builder.categories.find(params[:id])
  end

  def destroy
    @category= @builder.categories.find(params[:id])
    @id = params[:id]
    params[:with_associations].present? ? @category.destroy_with_associations : @category.destroy
    respond_to do |format|
      format.html do
        if @category.errors.any?
          render :delete
        else
          redirect_to(:action => 'list')
        end
      end
      format.js
    end
  end

  def items
    category = Category.find(params[:id])

    respond_to do |format|
      format.json { render json: category.items.select("id, name") }
    end
  end

end
