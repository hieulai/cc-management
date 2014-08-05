class LeadsController < ApplicationController

  before_filter :authenticate_user!
  
  def list_current_leads
    @projects = @builder.projects.current_lead.order("lead_stage ASC")
  end
  
  def list_past_leads
    @projects = @builder.projects.past_lead
  end
  
  def new_client
    @project = @builder.projects.new
    @client =  @builder.clients.new
  end
  
  def existing_client
    @project = @builder.projects.new
  end
  
  def create_from_new
    @client = @builder.clients.create(params[:client])
    @project = @builder.projects.new(params[:project].merge(:client_id => @client.id))
    if @project.save
      redirect_to(:action => 'list_current_leads')
    else
      render('new_client')
    end
  end
  
  def create_from_existing
    @client = @builder.clients.find(params[:client][:id])
    @project = @builder.projects.create(params[:project].merge(:client_id => @client.id))
    if @project.save
      redirect_to(:action => 'list_current_leads')
    else
      render('existing_client')
    end
  end
  
  def show
    @project = @builder.projects.find(params[:id])
    @client = @builder.clients.find(@project.client_id)
  end
  
  def edit
    @project = @builder.projects.find(params[:id])
    @client = @builder.clients.find(@project.client_id)
  end

  def update
    @project = @builder.projects.find(params[:id])
    @client = @project.client
    if  @project.update_attributes(params[:project]) && @client.update_attributes(params[:client])
      respond_to do |format|
        format.html { redirect_to(url_for(:action => 'list_current_leads')) }
        format.js { render :js => "window.location = '#{ url_for(:action => "list_current_leads")}'" }
      end
    else
      respond_to do |format|
        format.html { render('edit') }
        format.js { render "lead_response" }
      end
    end
  end

  def commit_estimate
    @estimate = @builder.estimates.find(params[:id])
    @estimate.update_attributes(:committed => true)
    respond_to do |format|
      format.js {}
    end
  end
  
  def delete
    @project = @builder.projects.find(params[:id])
  end
  
  def destroy
    @project = @builder.projects.find(params[:id])
    if @project.destroy
      redirect_to(:action => 'list_current_leads')
    else
      render('delete')
    end
  end
end
