module ApplicationHelper
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s, :f => builder)
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

end
