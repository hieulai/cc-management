class ItemsController < ApplicationController
  include ItemsHelper
  before_filter :authenticate_user!

  def list
    @query = params[:query]
    @items = Item.where(builder_id: session[:builder_id]).order(:name).search(@query)
    respond_to do |format|
      format.html
      format.csv {send_data Item.to_csv(@items)}
      format.xls { send_data @items.to_xls(:headers => Item::HEADERS, :columns => [:name, :description, :estimated_cost, :unit, :margin, :price, :notes]), content_type: 'application/vnd.ms-excel', filename: 'items.xls' }
    end
  end

  def new
    @item = Item.new
    @categories = Category.all
  end

  def create
    @builder = Base::Builder.find(session[:builder_id])
    @category = Category.find(params[:category][:id]) unless params[:category].blank?
    @item = Item.new(params[:item])

    if @item.save
      @item.categories << @category if @category
      @builder.items << @item
      redirect_to(action: 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render action: 'new', notice: "failed."
    end
  end

  def edit
    @item = Item.find(params[:id])
    @categories = Category.all
    @category = @item.categories_templates.first.id unless @item.categories_templates.blank?
  end

  def update
    @item = Item.find(params[:id])
    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html { redirect_to(:action => 'list') }
        format.json { render json: @item.to_json(:methods => [:amount, :price]) }
      else
        format.html { render('edit') }
        format.json do
          msg = @item.errors.full_messages.join(".")
          if @item.errors.has_key? :invoice
            msg+=  invoice_list @item
          end
          msg =
          render :json => {:errors => msg}, :status => 500
        end
      end
    end
  end

  def delete
    @item = Item.find(params[:id])
  end

  def destroy
    @id = params[:id]
    @item = Item.find(params[:id])
    respond_to do |format|
      if @item.destroy
        format.html { redirect_to(:action => 'list') }
        format.js
      else
        format.html { render('edit') }
        format.js
      end
    end
  end

  def transfer_data
    @item = Item.new
  end

  def import_export
    @item = Item.new
  end

  def import
    if params[:item].nil?
      redirect_to action: 'import_export', notice: "No file to import."
    else
      begin
        result = Item.import(params[:item][:data], @builder)
        msg = "Item imported."
        unless result[:errors].empty?
          msg = result[:errors].join(",")
        end
        redirect_to action: 'list', notice: msg
      rescue StandardError => e
        redirect_to action: 'import_export', notice: e
      end
    end
  end

  def autocomplete_name
    @items = @builder.items.search_by_name(params[:term])
    render :json => @items.map { |i| {:id => i.id,
                                      :label => i.name,
                                      :value => i.name,
                                      :unit => i.unit,
                                      :description => i.description,
                                      :qty => i.qty,
                                      :estimated_cost => i.estimated_cost,
                                      :margin => i.margin} }.to_json
  end

end
