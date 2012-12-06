module ApplicationHelper
  def navigation menus
    ret = "<ul class='navigation'>"
    menus.each { |m| ret += "<li><a href='#{m[:path]}'>#{m[:text]}</a></li>" }
    ret += '</ul>'
    ret.html_safe
  end

  def current_user_id
    current_user.id
  end

  def default_content_for(name, &block)
    name = name.kind_of?(Symbol) ? ":#{name}" : name
    out = eval("yield #{name}", block.binding)
    concat(out || capture(&block))
  end

  def max_price
    Camera.calculate_price(Camera.maximum('price').to_s).to_i
  end

  def max_zoom
    Camera.calculate_price(Camera.maximum('zoom').to_s).to_i
  end

  def max_megapixel
    Camera.calculate_price(Camera.maximum('megapixels').to_s).to_i
  end

  def amazon_product_link(link)
    product_code = link.split("/")[5].split("%").first
    product_link = "http://www.amazon.com/gp/product/" + product_code + "/ref=as_li_ss_tl?ie=UTF8&tag=ope06-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=" + product_code
    CGI.unescape(product_link)
  end
end
