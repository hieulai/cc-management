class TasklistsController < ApplicationController

  before_filter :authenticate_user!

  def list
    @tasklists = @builder.tasklists
  end
  
  def show
    @tasklist = Tasklist.find(params[:id])
    respond_to do |format|
      format.html
      format.csv { send_data @tasklist.to_csv, filename: "Tasklist-#{@tasklist.name}.csv"  }
      format.xls { send_data @tasklist.tasks.to_xls(:headers => Task::HEADERS, :columns => [:name, :completed, :time_to_complete, :department]), content_type: 'application/vnd.ms-excel', filename: "Tasklist-#{@tasklist.name}.xls" }
    end
  end
  
  def new
    @tasklist = Tasklist.new
    @tasklist.tasks.build
  end
  
  def create
    @builder = Base::Builder.find(session[:builder_id])
    @tasklist = Tasklist.new(params[:tasklist])
    #saves creation of Estimate
    if @tasklist.save
      @builder.tasklists << @tasklist
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end
  
  def edit
    @tasklist = Tasklist.find(params[:id])
  end
  
  def update
    #Find object using form parameters
    @tasklist = Tasklist.find(params[:id])
    #Update subject
    if @tasklist.update_attributes(params[:tasklist])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end

  def show_import
    @tasklist = Tasklist.new
  end

  def import
    if params[:tasklist].nil? || params[:tasklist][:data].nil?
      redirect_to action: 'show_import', notice: "No file to import."
    else
      begin
        tasklist = Tasklist.create(name: params[:tasklist][:name], builder_id: session[:builder_id])
        result = Task.import(params[:tasklist][:data])
        tasklist.tasks << result[:objects]
        msg = "Tasklist imported."
        unless result[:errors].empty?
          msg = result[:errors].join(",")
        end
        redirect_to action: 'list', notice: msg
      rescue StandardError => e
        redirect_to action: 'show_import', notice: e
      end
    end
  end

  def delete
    @tasklist = Tasklist.find(params[:id])
  end

  def destroy
    Tasklist.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end
end
