class ItemsController < ApplicationController
  include ItemsHelper
  before_filter :authenticate_user!
  before_filter :set_scope

  def set_scope
    @scope = request.path.split('/')[1]
  end

  def index
    respond_to do |format|
      format.html do
        @query = params[:query]
        @items = Item.search {
          fulltext params[:query]
          with :builder_id, session[:builder_id]
          order_by params[:sort_field].to_sym, params[:sort_dir].to_sym if params[:sort_field] && params[:sort_dir]
          paginate :page => params[:page], :per_page => Kaminari.config.default_per_page
        }.results
      end
      format.csv {send_data Item.to_csv(@builder.items)}
      format.xls { send_data @builder.items.to_xls(:headers => Item::HEADERS, :columns => [:name, :description, :estimated_cost, :unit, :margin, :price, :notes]), content_type: 'application/vnd.ms-excel', filename: 'items.xls' }
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
      redirect_to url_for([@scope.to_sym, :items])
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
        format.html { redirect_to url_for([@scope.to_sym, :items]) }
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
        format.html { redirect_to url_for([@scope.to_sym, :items]) }
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
        redirect_to  url_for([@scope.to_sym, :items]), notice: msg
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

  def search_by_name_and_description
    items = []
    unless params[:categories_template_id].blank?
      categories_template = CategoriesTemplate.find(params[:categories_template_id])
      all_items = (categories_template.items + categories_template.co_items).flatten
      items = all_items.select { |i| i.name == params[:name] && i.description == params[:description] }
    end

    if items.size > 0
      render :json => {:id => items[0].id,
                       :name => items[0].name,
                       :description => items[0].description,
                       :amount => items[0].amount}.to_json
    else
      render :json => {}.to_json
    end

  end

end
