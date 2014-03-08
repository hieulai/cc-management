class ClientsController < ApplicationController
  before_filter :authenticate_user!

  def list
    @query = params[:query]
    @clients = Client.search {
      fulltext params[:query]
      with :builder_id, session[:builder_id]
      with :status, "Active"
      paginate :page => params[:page], :per_page => Kaminari.config.default_per_page
    }.results
  end

  def show
    @client = Client.find(params[:id])
  end

  def new
    @client =  Client.new
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
    @client = Client.find(params[:id])
  end

  def update
    @client = Client.find(params[:id])
    if @client.update_attributes(params[:client])
      redirect_to(:action => 'list')
    else
      render('edit')
    end
  end

  def delete
    @client= Client.find(params[:id])
  end

  def destroy
    Client.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end

end
