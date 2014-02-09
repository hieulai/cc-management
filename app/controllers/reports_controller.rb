class ReportsController < ApplicationController
  before_filter :authenticate_user!

  def pl_report
    @from_date = Date.parse(params[:from_date])
    @to_date = Date.parse(params[:to_date])
    respond_to do |format|
      format.pdf do
        render :pdf => "Profit-Loss-Report-#{@from_date}-#{@to_date}",
               :layout => 'pdf.html',
               #:show_as_html => true,
               :footer => {:center => 'Page [page]'}
      end
    end
  end
end
