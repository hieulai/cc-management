class SpecificationsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @estimate = @builder.estimates.find(params[:estimate_id])
    @specifications = @estimate.specifications
  end

  def new
    @estimate = @builder.estimates.find(params[:estimate_id])
    @specification = @estimate.specifications.new
  end

  def create
    @specification = @builder.specifications.new(params[:specification])
    @category = @builder.categories.raw.find(params[:category][:id])
    @specification.category = @category
    if @specification.save
      redirect_to(:action => 'index', :estimate_id => @specification.estimate_id)
    else
      render('new')
    end
  end

  def edit
    @specification = @builder.specifications.find(params[:id])
    @category = @specification.category
  end

  def update
    @specification = @builder.specifications.find(params[:id])
    @category = @builder.categories.raw.find(params[:category][:id])
    @specification.category = @category
    if @specification.update_attributes(params[:specification])
      redirect_to(:action => 'index', :estimate_id => @specification.estimate_id)
    else
      render('new')
    end
  end

  def delete
    @specification = @builder.specifications.find(params[:id])
  end

  def destroy
    @specification = @builder.specifications.find(params[:id])
    estimate_id = @specification.estimate_id
    if @specification.destroy
      redirect_to(:action => 'index', :estimate_id => estimate_id)
    else
      render('destroy')
    end
  end
end
