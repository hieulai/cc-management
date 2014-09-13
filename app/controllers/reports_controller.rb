class ReportsController < ApplicationController
  before_filter :authenticate_user!

  def pl_report
    print_report "Profit-Loss-Report"
  end

  def project_expense_report
    print_report "Profit-Expense-Report"
  end

  private
  def print_report(report_name=nil)
    @project_id = params[:project_id]
    @from_date = Date.parse(params[:from_date])
    @to_date = Date.parse(params[:to_date])
    name = "#{report_name}-#{@from_date}-#{@to_date}"
    if @project_id.present?
      project = @builder.projects.find(@project_id)
      name = "#{report_name}-#{project.name}-#{@from_date}-#{@to_date}"
    end
    respond_to do |format|
      format.pdf do
        render :pdf => name,
               :layout => 'pdf.html',
               :show_as_html => params[:debug].present?,
               :footer => {:center => 'Page [page]'}
      end
    end
  end
end
