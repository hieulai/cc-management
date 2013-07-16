class CategoriesController < ApplicationController
  
  before_filter :confirm_logged_in
  
  def list
    @categories = Category.where("builder_id = ?", session[:builder_id])
  end

  def new
    @category = Category.new
  end

  def create
    @builder = Builder.find(session[:builder_id])
    @category = Category.new(params[:category])

    if @category.save
      @builder.categories << @category
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
