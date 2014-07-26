class ClientsController < ApplicationController
  before_filter :authenticate_user!

  def list
    @query = params[:query]
    @clients = Client.search {
      fulltext params[:query]
      with :builder_id, session[:builder_id]
      with :status, "Active"
      order_by params[:sort_field].to_sym, params[:sort_dir].to_sym if params[:sort_field] && params[:sort_dir]
      paginate :page => params[:page], :per_page => Kaminari.config.default_per_page
    }.results
  end

  def show
    @client = @builder.clients.find(params[:id])
  end

  def new
    @client =  @builder.clients.new
  end

  def create
    @client = @builder.clients.new(params[:client].merge(:status => "Active"))
    if @client.save
      redirect_to(:action => 'list')
    else
      render('new')
    end
  end

  def edit
    @client = @builder.clients.find(params[:id])
  end

  def update
    @client = @builder.clients.find(params[:id])
    if @client.update_attributes(params[:client])
      redirect_to(:action => 'list')
    else
      render('edit')
    end
  end

  def delete
    @client = @builder.clients.find(params[:id])
  end

  def destroy
    @client = @builder.clients.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end

end
