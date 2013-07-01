class CategoriesController < ApplicationController
  
  before_filter :confirm_logged_in
  
  def list
    @categories = Category.all
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(params[:category])

    if @category.save
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end

  def edit
    @category= Category.find(params[:id])
  end

  def update
    #Find object using form parameters
    @category = Category.find(params[:id])
    #Update subject
    if @category.update_attributes(params[:category])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end

  def delete
    @category= Category.find(params[:id])
  end

  def destroy
    Category.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end

  def items
    category = Category.find(params[:id])

    respond_to do |format|
      format.json { render json: category.items.select("id, name") }
    end
  end

end
