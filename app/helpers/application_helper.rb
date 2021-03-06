module ApplicationHelper
  def icon_tag(img, tooltip)
    image_tag "silk/#{img}.png", :alt => img, :title => tooltip
  end
  def read_only(form)
    model = form.object
    method = form.options[:html][:method]
    if(method == :put)
      return(!model.permitted_to? :update)
    else
      return(!model.permitted_to? :create)
    end
  end
  

  
  def read_only_object(model)
      return(!model.permitted_to? :update)
  end
end
