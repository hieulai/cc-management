module ApplicationHelper
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"))
  end

  def active_page(page_name, menu_type, act_name = nil)
    menu_bar_1, menu_bar_2 = 'nav', 'subnav'
    if page_name.include?(controller_name) && menu_bar_1.eql?(menu_type) && act_name.nil?
      'active'
    elsif (controller_name.eql?(page_name)) && action_name.eql?(act_name)
      'active'
    else
      ''
    end
  end

  def price n
    n.nil? ? n : number_to_currency(number_with_precision(n, precision: 2), :unit =>"")
  end

  def price_tag n, inner_class = ""
    n.nil? ? n : raw(content_tag(:div, number_to_currency(number_with_precision(n, precision: 2)), :class => inner_class))
  end

  def pdf_image_tag(image, options = {})
    options[:src] =  image
    tag(:img, options)
  end

  def select2_account_json
    json = []
    Account.raw(session[:builder_id]).top.each do |a|
      json << a.as_select2_json
    end
    json.to_json
  end

end
