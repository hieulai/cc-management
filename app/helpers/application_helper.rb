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
    if page_name.include?(controller_name) && act_name.nil?
      'active'
    elsif (controller_name.eql?(page_name)) && action_name.eql?(act_name)
      'active'
    else
      ''
    end
  end

  def active_nav(page_name, c_name= nil, act_name = nil)
    root_path = request.path.split('/')[1]
    if page_name.include?(root_path) &&
        (c_name.nil? || (c_name.include?(controller_name) &&
            (act_name.nil? || act_name.include?(action_name))))
      'active'
    else
      ''
    end
  end

  def sorted_ths(names = [])
    tag = ""
    names.each do |field|
      class_name = 'sorting'
      sort_dir = "asc"
      if params[:sort_field] == field[1]
        if params[:sort_dir] == "asc"
          class_name = "sorting_asc"
          sort_dir = "desc"
        else
          class_name = "sorting_desc"
        end
      end
      class_name+= " #{field[2]}" if field[2]
      tag += content_tag :th, :class => class_name do
        link_to(field[0], params.merge(sort_field: field[1], sort_dir: sort_dir))
      end
    end
    raw(tag)
  end

  def price n
    n.nil? ? n : number_to_currency(number_with_precision(n.to_f.round(2), precision: 2), :unit =>"")
  end

  def price_tag n, inner_class = ""
    n.nil? ? n : raw(content_tag(:div, number_to_currency(number_with_precision(n.to_f.round(2), precision: 2)), :class => "#{inner_class} nowrap"))
  end

  def pdf_image_tag(image, options = {})
    options[:src] =  image
    tag(:img, options)
  end

  def select2_account_json
    json = []
    @builder.accounts.top.each do |a|
      json << a.as_select2_json
    end
    json.to_json
  end

end
