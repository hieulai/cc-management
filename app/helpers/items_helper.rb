module ItemsHelper
  def invoice_list item
    l = "<br/>"
    l+= "<ul>"
    item.invoices.each do |i|
      if defined? view_context
        link = view_context.link_to("Invoice #{i.id}", {:controller => 'accounting', :action => 'edit_invoice', :id => i.id}, :target => "_blank")
      else
        link = link_to("Invoice #{i.id}", {:controller => 'accounting', :action => 'edit_invoice', :id => i.id}, :target => "_blank")
      end
      l+= "<li>" + link + "</li>"
    end
    l+="</ul>"
    l
  end
end