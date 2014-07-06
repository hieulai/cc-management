class BidsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @estimate = @builder.estimates.find(params[:estimate_id])
    @bids = @estimate.bids
  end

  def new
    @estimate = @builder.estimates.find(params[:estimate_id])
    @bid = @estimate.bids.new
  end

  def create
    @bid = @builder.bids.new(params[:bid])
    if @bid.save
      redirect_to(:action => 'index', :estimate_id => @bid.estimate_id)
    else
      render('new')
    end
  end

  def edit
    @bid = @builder.bids.find(params[:id])
  end

  def update
    @bid = @builder.bids.find(params[:id])
    # Destroy all old bids_items if category changed
    if params[:bid][:category_id].present? && @bid.category_id.to_s != params[:bid][:category_id]
      @bid.bids_items.each do |bi|
        params[:bid][:bids_items_attributes] << {id: bi.id, _destroy: true}.with_indifferent_access
      end
    end
    if @bid.update_attributes(params[:bid])
      redirect_to(:action => 'index', :estimate_id => @bid.estimate_id)
    else
      render('edit')
    end
  end

  def delete
    @bid = @builder.bids.find(params[:id])
  end

  def destroy
    @bid = @builder.bids.find(params[:id])
    if @bid.destroy
      redirect_to(:action => 'index', :estimate_id => @bid.estimate_id)
    else
      render('delete')
    end
  end


  def show_estimate_items
    @estimate = @builder.estimates.find(params[:estimate_id])
    @bid = params[:id].present? ? @estimate.bids.find(params[:id]) : @estimate.bids.new
    categories_template = CategoriesTemplate.where(:category_id => params[:bid][:category_id], :template_id => @estimate.template.id).first
    if categories_template
      @items = categories_template.items
      @co_items = @estimate.project.co_items(categories_template.category)
    else
      change_orders_categories = ChangeOrdersCategory.where('category_id = ? AND change_order_id in (?)', params[:bid][:category_id], @estimate.project.change_orders.pluck(:id))
      @co_items = change_orders_categories.map(&:items).flatten
    end
    respond_to do |format|
      format.js {}
    end
  end
end
